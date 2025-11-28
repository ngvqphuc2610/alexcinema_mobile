import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import { DocumentIndexerService } from './document-indexer.service';

/**
 * Event listener for auto re-indexing RAG data when database changes
 */
@Injectable()
export class RagEventsListener implements OnModuleInit {
    private readonly logger = new Logger(RagEventsListener.name);
    private indexingQueue: Set<string> = new Set();
    private indexingTimer: NodeJS.Timeout | null = null;
    private readonly DEBOUNCE_DELAY = 5000; // 5 seconds

    constructor(private readonly indexer: DocumentIndexerService) { }

    // ==========================================
    // 1. LOGIC SMART SYNC (Khi khởi động)
    // ==========================================
    async onModuleInit() {
        this.logger.log('Checking Qdrant data integrity on startup...');
        
        // Chạy ngầm background để không block app start
        this.checkAndSyncData().catch(err => {
            this.logger.error('Failed to sync data on startup', err);
        });
    }
    
    async checkAndSyncData() {
        try {
            this.logger.log('Starting Smart Sync Check...');

            // --- 1. Movies ---
            const [dbMovies, qdrantMovies] = await Promise.all([
                this.indexer.countMoviesInDb(),
                this.indexer.countMoviesInQdrant()
            ]);

            if (dbMovies !== qdrantMovies) {
                this.logger.warn(`Mismatch in Movies (DB: ${dbMovies} vs Qdrant: ${qdrantMovies}). Re-indexing...`);
                await this.indexer.resetMoviesCollection();
            } else {
                this.logger.log(`Movies are in sync (${dbMovies}).`);
            }

            // --- 2. Showtimes ---
            const [dbShowtimes, qdrantShowtimes] = await Promise.all([
                this.indexer.countShowtimesInDb(),
                this.indexer.countShowtimesInQdrant()
            ]);

            if (dbShowtimes !== qdrantShowtimes) {
                this.logger.warn(`Mismatch in Showtimes (DB: ${dbShowtimes} vs Qdrant: ${qdrantShowtimes}). Re-indexing...`);
                await this.indexer.resetShowtimesCollection();
            } else {
                 this.logger.log(`Showtimes are in sync (${dbShowtimes}).`);
            }

            // --- 3. Promotions ---
            const [dbPromotions, qdrantPromotions] = await Promise.all([
                this.indexer.countPromotionsInDb(),
                this.indexer.countPromotionsInQdrant()
            ]);
            
            if (dbPromotions !== qdrantPromotions) {
                this.logger.warn(`Mismatch in Promotions (DB: ${dbPromotions} vs Qdrant: ${qdrantPromotions}). Re-indexing...`);
                await this.indexer.resetPromotionsCollection();
            } else {
                this.logger.log(`Promotions are in sync (${dbPromotions}).`);
            }

            // --- 4. Cinemas ---
            const [dbCinemas, qdrantCinemas] = await Promise.all([
                this.indexer.countCinemasInDb(),
                this.indexer.countCinemasInQdrant()
            ]);

            if (dbCinemas !== qdrantCinemas) {
                this.logger.warn(`Mismatch in Cinemas (DB: ${dbCinemas} vs Qdrant: ${qdrantCinemas}). Re-indexing...`);
                await this.indexer.resetCinemasCollection();
            } else {
                this.logger.log(`Cinemas are in sync (${dbCinemas}).`);
            }

        } catch (error) {
            this.logger.error(`Failed to smart sync data: ${error.message}`);
        }
    }

    // ==========================================
    // 2. LOGIC XỬ LÝ SỰ KIỆN (REAL-TIME)
    // ==========================================

    /**
     * Handle movie created/updated -> RE-INDEX (Upsert)
     */
    @OnEvent('movie.created')
    @OnEvent('movie.updated')
    async handleMovieChange(payload: any) {
        this.logger.log(`Movie change detected: ${payload.id}`);
        this.scheduleReindex('movies');
    }

    /**
     * Handle movie deleted -> DELETE TRỰC TIẾP
     */
    @OnEvent('movie.deleted')
    async handleMovieDeleted(payload: any) {
        this.logger.log(`Movie deleted: ${payload.id}`);
        // SỬA: Gọi hàm xóa trực tiếp, không re-index
        await this.indexer.deleteMovie(payload.id);
    }

    /**
     * Handle showtime created/updated -> RE-INDEX
     */
    @OnEvent('showtime.created')
    @OnEvent('showtime.updated')
    async handleShowtimeChange(payload: any) {
        this.logger.log(`Showtime change detected: ${payload.id}`);
        this.scheduleReindex('showtimes');
    }

    /**
     * Handle showtime deleted -> DELETE TRỰC TIẾP
     */
    @OnEvent('showtime.deleted')
    async handleShowtimeDeleted(payload: any) {
        this.logger.log(`Showtime deleted: ${payload.id}`);
        await this.indexer.deleteShowtime(payload.id);
    }

    /**
     * Handle promotion created/updated -> RE-INDEX
     */
    @OnEvent('promotion.created')
    @OnEvent('promotion.updated')
    async handlePromotionChange(payload: any) {
        this.logger.log(`Promotion change detected: ${payload.id}`);
        this.scheduleReindex('promotions');
    }

    /**
     * Handle promotion deleted -> DELETE TRỰC TIẾP
     */
    @OnEvent('promotion.deleted')
    async handlePromotionDeleted(payload: any) {
        this.logger.log(`Promotion deleted: ${payload.id}`);
        await this.indexer.deletePromotion(payload.id);
    }

    /**
     * Handle cinema created/updated -> RE-INDEX
     */
    @OnEvent('cinema.created')
    @OnEvent('cinema.updated')
    async handleCinemaChange(payload: any) {
        this.logger.log(`Cinema change detected: ${payload.id}`);
        this.scheduleReindex('cinemas');
    }

    /**
     * Handle cinema deleted -> DELETE TRỰC TIẾP
     */
    @OnEvent('cinema.deleted')
    async handleCinemaDeleted(payload: any) {
        this.logger.log(`Cinema deleted: ${payload.id}`);
        await this.indexer.deleteCinema(payload.id);
    }

    // ==========================================
    // 3. LOGIC DEBOUNCE RE-INDEXING
    // ==========================================

    private scheduleReindex(collection: string) {
        this.indexingQueue.add(collection);

        if (this.indexingTimer) {
            clearTimeout(this.indexingTimer);
        }

        this.indexingTimer = setTimeout(() => {
            this.executeReindex();
        }, this.DEBOUNCE_DELAY);
    }

    private async executeReindex() {
        const collections = Array.from(this.indexingQueue);
        this.indexingQueue.clear();

        this.logger.log(`Starting debounce re-indexing for: ${collections.join(', ')}`);

        for (const collection of collections) {
            try {
                let count = 0;
                switch (collection) {
                    case 'movies':
                        count = await this.indexer.indexMovies();
                        break;
                    case 'showtimes':
                        count = await this.indexer.indexShowtimes();
                        break;
                    case 'promotions':
                        count = await this.indexer.indexPromotions();
                        break;
                    case 'cinemas':
                        count = await this.indexer.indexCinemas();
                        break;
                }
                this.logger.log(`Re-indexed ${count} items in ${collection}`);
            } catch (error) {
                this.logger.error(`Failed to re-index ${collection}: ${error.message}`);
            }
        }
    }
}