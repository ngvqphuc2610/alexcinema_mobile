import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

export interface QdrantPoint {
    id: string | number;
    vector: number[];
    payload: Record<string, any>;
}

export interface SearchResult {
    id: string | number;
    score: number;
    payload: Record<string, any>;
}

@Injectable()
export class QdrantService implements OnModuleInit {
    private readonly logger = new Logger(QdrantService.name);
    private readonly qdrantUrl: string;
    private readonly vectorSize = 768; // Gemini text-embedding-004 dimension

    constructor(
        private readonly configService: ConfigService,
        private readonly httpService: HttpService,
    ) {
        this.qdrantUrl = this.configService.get<string>('QDRANT_URL', 'http://localhost:6333');
    }

    async onModuleInit() {
        await this.ensureCollections();
    }

    async countCollection(collectionName: string): Promise<number> {
        try {
            const result = await firstValueFrom(
                this.httpService.get(`${this.qdrantUrl}/collections/${collectionName}`),
            );
            // FIX: Qdrant trả về data.result.points_count, không phải data.points_count
            return result.data.result?.points_count ?? 0;
        } catch (error) {
            // Nếu collection chưa tồn tại hoặc lỗi, coi như là 0
            return 0;
        }
    }

    /**
     * Delete specific points from collection
     */
    async deletePoints(collectionName: string, ids: (string | number)[]): Promise<void> {
        const url = `${this.qdrantUrl}/collections/${collectionName}/points/delete`;

        try {
            await firstValueFrom(
                this.httpService.post(url, {
                    points: ids,
                }),
            );
            this.logger.log(`Deleted ${ids.length} points from ${collectionName}`);
        } catch (error) {
            this.logger.error(`Failed to delete points: ${error.message}`);
            throw error;
        }
    }

    /**
     * Create collection if not exists
     */
    private async ensureCollections() {
        const collections = ['movies', 'showtimes', 'promotions', 'faqs', 'cinemas'];

        for (const collectionName of collections) {
            try {
                await this.createCollection(collectionName);
                this.logger.log(`Collection "${collectionName}" ready`);
            } catch (error) {
                this.logger.warn(`Collection "${collectionName}" already exists or error: ${error.message}`);
            }
        }
    }

    /**
     * Create a new collection in Qdrant
     */
    async createCollection(collectionName: string): Promise<void> {
        const url = `${this.qdrantUrl}/collections/${collectionName}`;

        try {
            await firstValueFrom(
                this.httpService.put(url, {
                    vectors: {
                        size: this.vectorSize,
                        distance: 'Cosine',
                    },
                    optimizers_config: {
                        indexing_threshold: 10000,
                    },
                }),
            );
        } catch (error) {
            if (error.response?.status !== 409) {
                throw error;
            }
        }
    }

    /**
     * Upsert points (documents) into collection
     */
    async upsertPoints(
        collectionName: string,
        points: QdrantPoint[],
    ): Promise<void> {
        const url = `${this.qdrantUrl}/collections/${collectionName}/points`;

        try {
            await firstValueFrom(
                this.httpService.put(url, {
                    points,
                }),
            );

            this.logger.log(`Upserted ${points.length} points to ${collectionName}`);
        } catch (error) {
            this.logger.error(`Failed to upsert points: ${error.message}`);
            throw error;
        }
    }

    /**
     * Search for similar vectors
     */
    async search(
        collectionName: string,
        queryVector: number[],
        limit: number = 5,
        filter?: Record<string, any>,
    ): Promise<SearchResult[]> {
        const url = `${this.qdrantUrl}/collections/${collectionName}/points/search`;

        try {
            const response = await firstValueFrom(
                this.httpService.post(url, {
                    vector: queryVector,
                    limit,
                    with_payload: true,
                    filter,
                }),
            );

            return response.data.result.map((item: any) => ({
                id: item.id,
                score: item.score,
                payload: item.payload,
            }));
        } catch (error) {
            this.logger.error(`Search failed: ${error.message}`);
            throw error;
        }
    }

    /**
     * Delete collection
     */
    async deleteCollection(collectionName: string): Promise<void> {
        const url = `${this.qdrantUrl}/collections/${collectionName}`;

        try {
            await firstValueFrom(this.httpService.delete(url));
            this.logger.log(`Deleted collection: ${collectionName}`);
        } catch (error) {
            this.logger.error(`Failed to delete collection: ${error.message}`);
            throw error;
        }
    }
}
