import { Injectable, Logger } from '@nestjs/common';
import { QdrantService } from './qdrant.service';
import { EmbeddingsService } from './embeddings.service';
import { PrismaService } from '../prisma/prisma.service';

export interface RagSearchResult {
    context: string;
    sources: Array<{
        type: string;
        title: string;
        score: number;
        data: Record<string, any>;
    }>;
}

@Injectable()
export class RagService {
    private readonly logger = new Logger(RagService.name);

    constructor(
        private readonly qdrant: QdrantService,
        private readonly embeddings: EmbeddingsService,
        private readonly prisma: PrismaService,
    ) { }

    /**
     * Search for relevant context based on user query
     * @param query User's question/query
     * @param limit Maximum number of results per collection
     * @returns Augmented context and sources
     */
    private normalizeQuery(query: string): string {
        return query
            .toLowerCase()
            .trim()
            .normalize('NFD')  // Bỏ dấu tiếng Việt nếu cần
            .replace(/[\u0300-\u036f]/g, '')  // Remove accents
            .replace(/[^a-z0-9\s]/gi, ' ')  // Remove special chars
            .replace(/\s+/g, ' ');  // Collapse spaces
    }
    async search(query: string, limit: number = 3): Promise<RagSearchResult> {
        try {
            // Generate embedding for the query
            const normalizedQuery = this.normalizeQuery(query);
            const queryVector = await this.embeddings.generateEmbedding(normalizedQuery);

            // Search across all collections in parallel
            const [movieResults, showtimeResults, promotionResults, cinemaResults] = await Promise.all([
                this.qdrant.search('movies', queryVector, limit).catch(() => []),
                this.qdrant.search('showtimes', queryVector, limit).catch(() => []),
                this.qdrant.search('promotions', queryVector, limit).catch(() => []),
                this.qdrant.search('cinemas', queryVector, limit).catch(() => []),
            ]);

            // Combine and sort by score
            const allResults = [
                ...movieResults.map(r => ({ ...r, collection: 'movies' })),
                ...showtimeResults.map(r => ({ ...r, collection: 'showtimes' })),
                ...promotionResults.map(r => ({ ...r, collection: 'promotions' })),
                ...cinemaResults.map(r => ({ ...r, collection: 'cinemas' })),
            ]
                .sort((a, b) => b.score - a.score)
                .slice(0, limit * 3); // Get top results overall

            // Format context for Gemini
            const context = this.formatContext(allResults);

            // Format sources
            const sources = allResults.map(result => ({
                type: result.payload.type,
                title: result.payload.title || result.payload.movieTitle || result.payload.name || 'Unknown',
                score: result.score,
                data: result.payload,
            }));

            return { context, sources };
        } catch (error) {
            this.logger.error(`RAG search failed: ${error.message}`);
            return { context: '', sources: [] };
        }
    }

    /**
     * Hybrid Search: Combines Vector Search (semantic) + Keyword Search (exact match)
     * @param query User's search query
     * @param limit Maximum results to return
     * @returns Combined and ranked results
     */
    async hybridSearch(query: string, limit: number = 5): Promise<RagSearchResult> {
        try {
            const normalizedQuery = this.normalizeQuery(query);

            // 1. Vector Search (Semantic)
            this.logger.log(`Hybrid Search - Vector search for: "${query}"`);
            const vectorSearchPromise = this.search(query, limit);

            // 2. Keyword Search (Exact/Fuzzy Match from Database)
            this.logger.log(`Hybrid Search - Keyword search for: "${query}"`);
            const keywordSearchPromise = this.keywordSearch(query, limit);

            // Run both searches in parallel
            const [vectorResults, keywordResults] = await Promise.all([
                vectorSearchPromise,
                keywordSearchPromise
            ]);

            // 3. Merge and deduplicate results
            const mergedResults = this.mergeResults(
                vectorResults.sources,
                keywordResults,
                query
            );

            // 4. Format context from merged results
            const context = this.formatHybridContext(mergedResults);

            return {
                context,
                sources: mergedResults.slice(0, limit * 2) // Return top results
            };
        } catch (error) {
            this.logger.error(`Hybrid search failed: ${error.message}`);
            // Fallback to regular vector search
            return this.search(query, limit);
        }
    }

    /**
     * Keyword search across database collections
     */
    private async keywordSearch(query: string, limit: number): Promise<any[]> {
        const results: any[] = [];

        try {
            // Search Movies
            const movies = await this.prisma.movies.findMany({
                where: {
                    OR: [
                        { title: { contains: query } },
                        { original_title: { contains: query } },
                        { description: { contains: query } },
                        { director: { contains: query } },
                        { actors: { contains: query } },
                    ]
                },
                take: limit,
                orderBy: { release_date: 'desc' }
            });

            movies.forEach(movie => {
                results.push({
                    type: 'movie',
                    title: movie.title,
                    score: this.calculateKeywordScore(query, movie.title),
                    data: {
                        type: 'movie',
                        id: movie.id_movie,
                        title: movie.title,
                        description: movie.description,
                        director: movie.director,
                        actors: movie.actors,
                        duration: movie.duration,
                        language: movie.language,
                        country: movie.country,
                        releaseDate: movie.release_date,
                        status: movie.status
                    }
                });
            });

            // Search Promotions
            const promotions = await this.prisma.promotions.findMany({
                where: {
                    AND: [
                        {
                            OR: [
                                { title: { contains: query } },
                                { description: { contains: query } },
                                { promotion_code: { contains: query } },
                            ]
                        },
                        { start_date: { lte: new Date() } },
                        { end_date: { gte: new Date() } },
                        { status: 'active' }
                    ]
                },
                take: limit
            });

            promotions.forEach(promo => {
                results.push({
                    type: 'promotion',
                    title: promo.title,
                    score: this.calculateKeywordScore(query, promo.title),
                    data: {
                        type: 'promotion',
                        id: promo.id_promotions,
                        title: promo.title,
                        description: promo.description,
                        promotionCode: promo.promotion_code,
                        discountPercent: promo.discount_percent,
                        discountAmount: promo.discount_amount,
                        startDate: promo.start_date,
                        endDate: promo.end_date
                    }
                });
            });

            // Search Cinemas
            const cinemas = await this.prisma.cinemas.findMany({
                where: {
                    OR: [
                        { cinema_name: { contains: query } },
                        { address: { contains: query } },
                        { city: { contains: query } },
                    ]
                },
                take: limit
            });

            cinemas.forEach(cinema => {
                results.push({
                    type: 'cinema',
                    title: cinema.cinema_name,
                    score: this.calculateKeywordScore(query, cinema.cinema_name),
                    data: {
                        type: 'cinema',
                        id: cinema.id_cinema,
                        name: cinema.cinema_name,
                        address: cinema.address,
                        city: cinema.city,
                        description: cinema.description,
                        contactNumber: cinema.contact_number,
                        email: cinema.email
                    }
                });
            });

        } catch (error) {
            this.logger.error(`Keyword search error: ${error.message}`);
        }

        return results;
    }

    /**
     * Calculate relevance score for keyword match
     */
    private calculateKeywordScore(query: string, text: string | null): number {
        if (!text) return 0.5;

        const queryLower = query.toLowerCase();
        const textLower = text.toLowerCase();

        // Exact match gets highest score
        if (textLower === queryLower) return 1.0;

        // Starts with query gets high score
        if (textLower.startsWith(queryLower)) return 0.9;

        // Contains query gets medium score
        if (textLower.includes(queryLower)) return 0.8;

        // Fuzzy match (words overlap)
        const queryWords = queryLower.split(' ');
        const textWords = textLower.split(' ');
        const matchCount = queryWords.filter(qw =>
            textWords.some(tw => tw.includes(qw) || qw.includes(tw))
        ).length;

        return 0.5 + (matchCount / queryWords.length) * 0.3;
    }

    /**
     * Merge vector and keyword search results, removing duplicates
     */
    private mergeResults(vectorSources: any[], keywordSources: any[], query: string): any[] {
        const merged = new Map<string, any>();

        // Add vector search results
        vectorSources.forEach(source => {
            const key = `${source.type}_${source.data.id || source.data.title}`;
            merged.set(key, {
                ...source,
                vectorScore: source.score,
                keywordScore: 0,
                source: 'vector'
            });
        });

        // Add/merge keyword search results
        keywordSources.forEach(source => {
            const key = `${source.type}_${source.data.id || source.data.title}`;

            if (merged.has(key)) {
                // Item found in both searches - boost score!
                const existing = merged.get(key);
                existing.keywordScore = source.score;
                existing.score = (existing.vectorScore * 0.6) + (source.score * 0.4); // Weighted avg
                existing.score += 0.1; // Bonus for being in both
                existing.source = 'hybrid';
            } else {
                // New item from keyword search
                merged.set(key, {
                    ...source,
                    vectorScore: 0,
                    keywordScore: source.score,
                    source: 'keyword'
                });
            }
        });

        // Convert to array and sort by final score
        return Array.from(merged.values())
            .sort((a, b) => b.score - a.score);
    }

    /**
     * Format hybrid search results into context
     */
    private formatHybridContext(results: any[]): string {
        if (results.length === 0) return '';

        // Group by type and format
        const movieResults = results.filter(r => r.type === 'movie');
        const promotionResults = results.filter(r => r.type === 'promotion');
        const cinemaResults = results.filter(r => r.type === 'cinema');
        const showtimeResults = results.filter(r => r.type === 'showtime');

        // Reuse existing formatContext by converting to expected format
        const formattedResults = results.map(r => ({
            payload: r.data,
            score: r.score
        }));

        return this.formatContext(formattedResults);
    }

    /**
     * Format search results into context string for Gemini
     */
    private formatContext(results: any[]): string {
        if (results.length === 0) {
            return '';
        }

        const sections: string[] = [];

        // Group by type
        const movieResults = results.filter(r => r.payload.type === 'movie');
        const showtimeResults = results.filter(r => r.payload.type === 'showtime');
        const promotionResults = results.filter(r => r.payload.type === 'promotion');
        const cinemaResults = results.filter(r => r.payload.type === 'cinema');

        // Format cinemas
        if (cinemaResults.length > 0) {
            sections.push('=== THÔNG TIN RẠP CHIẾU PHIM ===');
            cinemaResults.forEach(result => {
                const cinema = result.payload;
                const operationHours = cinema.operationHours?.map(oh =>
                    `${this.getDayName(oh.dayOfWeek)}: ${oh.openTime} - ${oh.closeTime}`
                ).join(', ') || 'N/A';

                sections.push(`
                                Tên rạp: ${cinema.name}
                                Địa chỉ: ${cinema.address}
                                Thành phố: ${cinema.city}
                                Mô tả: ${cinema.description || 'N/A'}
                                Số điện thoại: ${cinema.contactNumber || 'N/A'}
                                Email: ${cinema.email || 'N/A'}
                                Số phòng chiếu: ${cinema.screenCount}
                                Loại phòng: ${cinema.screenTypes?.join(', ') || 'N/A'}
                                Giờ mở cửa: ${operationHours}
                                `.trim());
            });
        }

        // Format movies
        if (movieResults.length > 0) {
            sections.push('\n=== THÔNG TIN PHIM ===');
            movieResults.forEach(result => {
                const movie = result.payload;
                sections.push(`
                            Tên phim: ${movie.title}
                            Thể loại: ${movie.genres || 'N/A'}
                            Đạo diễn: ${movie.director || 'N/A'}
                            Diễn viên: ${movie.actors || 'N/A'}
                            Mô tả: ${movie.description || 'N/A'}
                            Thời lượng: ${movie.duration || 'N/A'} phút
                            Ngôn ngữ: ${movie.language || 'N/A'}
                            Quốc gia: ${movie.country || 'N/A'}
        `.trim());
            });
        }

        // Format showtimes
        if (showtimeResults.length > 0) {
            sections.push('\n=== LỊCH CHIẾU ===');
            showtimeResults.forEach(result => {
                const showtime = result.payload;
                sections.push(`
                        Phim: ${showtime.movieTitle}
                        Rạp: ${showtime.cinemaName}
                        Địa chỉ: ${showtime.cinemaAddress}
                        Phòng: ${showtime.screenName}
                        Giờ chiếu: ${new Date(showtime.startTime).toLocaleString('vi-VN')}
                        Định dạng: ${showtime.format || '2D'}
                        Ngôn ngữ: ${showtime.language || 'N/A'}
                        Phụ đề: ${showtime.subtitle || 'N/A'}
                        Giá vé: ${parseInt(showtime.price).toLocaleString('vi-VN')} VNĐ
        `.trim());
            });
        }

        // Format promotions
        if (promotionResults.length > 0) {
            sections.push('\n=== KHUYẾN MÃI ===');
            promotionResults.forEach(result => {
                const promo = result.payload;
                sections.push(`
                    Tên: ${promo.title}
                    Mô tả: ${promo.description || 'N/A'}
                    Mã khuyến mãi: ${promo.promotionCode || 'N/A'}
                    Giảm giá: ${promo.discountPercent || 0}%
                    Giảm tiền: ${promo.discountAmount?.toLocaleString('vi-VN') || 0} VNĐ
                    Thời gian: ${new Date(promo.startDate).toLocaleDateString('vi-VN')} - ${new Date(promo.endDate).toLocaleDateString('vi-VN')}
                    Mua tối thiểu: ${promo.minPurchase?.toLocaleString('vi-VN') || 0} VNĐ
        `.trim());
            });
        }

        return sections.join('\n\n');
    }

    private getDayName(dayOfWeek: number): string {
        const dayNames = ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
        return dayNames[dayOfWeek] || 'N/A';
    }
}
