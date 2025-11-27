import { Injectable, Logger } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import { DocumentIndexerService } from './document-indexer.service';

/**
 * Event listener for auto re-indexing RAG data when database changes
 */
@Injectable()
export class RagEventsListener {
    private readonly logger = new Logger(RagEventsListener.name);
    private indexingQueue: Set<string> = new Set();
    private indexingTimer: NodeJS.Timeout | null = null;
    private readonly DEBOUNCE_DELAY = 5000; // 5 seconds

    constructor(private readonly indexer: DocumentIndexerService) { }

    /**
     * Handle movie created/updated events
     */
    @OnEvent('movie.created')
    @OnEvent('movie.updated')
    async handleMovieChange(payload: any) {
        this.logger.log(`Movie change detected: ${payload.id}`);
        this.scheduleReindex('movies');
    }

    /**
     * Handle movie deleted event
     */
    @OnEvent('movie.deleted')
    async handleMovieDeleted(payload: any) {
        this.logger.log(`Movie deleted: ${payload.id}`);
        this.scheduleReindex('movies');
    }

    /**
     * Handle showtime created/updated events
     */
    @OnEvent('showtime.created')
    @OnEvent('showtime.updated')
    async handleShowtimeChange(payload: any) {
        this.logger.log(`Showtime change detected: ${payload.id}`);
        this.scheduleReindex('showtimes');
    }

    /**
     * Handle showtime deleted event
     */
    @OnEvent('showtime.deleted')
    async handleShowtimeDeleted(payload: any) {
        this.logger.log(`Showtime deleted: ${payload.id}`);
        this.scheduleReindex('showtimes');
    }

    /**
     * Handle promotion created/updated events
     */
    @OnEvent('promotion.created')
    @OnEvent('promotion.updated')
    async handlePromotionChange(payload: any) {
        this.logger.log(`Promotion change detected: ${payload.id}`);
        this.scheduleReindex('promotions');
    }

    /**
     * Handle promotion deleted event
     */
    @OnEvent('promotion.deleted')
    async handlePromotionDeleted(payload: any) {
        this.logger.log(`Promotion deleted: ${payload.id}`);
        this.scheduleReindex('promotions');
    }

    /**
     * Handle cinema created/updated events
     */
    @OnEvent('cinema.created')
    @OnEvent('cinema.updated')
    async handleCinemaChange(payload: any) {
        this.logger.log(`Cinema change detected: ${payload.id}`);
        this.scheduleReindex('cinemas');
    }

    /**
     * Handle cinema deleted event
     */
    @OnEvent('cinema.deleted')
    async handleCinemaDeleted(payload: any) {
        this.logger.log(`Cinema deleted: ${payload.id}`);
        this.scheduleReindex('cinemas');
    }

    /**
     * Schedule re-indexing with debounce to avoid too frequent updates
     */
    private scheduleReindex(collection: string) {
        this.indexingQueue.add(collection);

        // Clear existing timer
        if (this.indexingTimer) {
            clearTimeout(this.indexingTimer);
        }

        // Schedule new indexing after debounce delay
        this.indexingTimer = setTimeout(() => {
            this.executeReindex();
        }, this.DEBOUNCE_DELAY);
    }

    /**
     * Execute re-indexing for all queued collections
     */
    private async executeReindex() {
        const collections = Array.from(this.indexingQueue);
        this.indexingQueue.clear();

        this.logger.log(`Starting re-indexing for: ${collections.join(', ')}`);

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
                this.logger.log(`Re-indexed ${count} ${collection}`);
            } catch (error) {
                this.logger.error(`Failed to re-index ${collection}: ${error.message}`);
            }
        }
    }
}
