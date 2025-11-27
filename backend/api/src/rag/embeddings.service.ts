import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class EmbeddingsService {
    private readonly logger = new Logger(EmbeddingsService.name);
    private readonly apiKey: string;
    private readonly model = 'text-embedding-004';
    private readonly apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

    constructor(
        private readonly configService: ConfigService,
        private readonly httpService: HttpService,
    ) {
        this.apiKey = this.configService.get<string>('GEMINI_API_KEY') || '';
        if (!this.apiKey) {
            this.logger.warn('GEMINI_API_KEY not found in environment variables');
        }
    }    /**
     * Generate embeddings using Gemini Embedding API
     * @param text Text to embed
     * @returns Vector embedding (768 dimensions)
     */
    async generateEmbedding(text: string): Promise<number[]> {
        try {
            const url = `${this.apiUrl}/${this.model}:embedContent?key=${this.apiKey}`;

            const response = await firstValueFrom(
                this.httpService.post(url, {
                    model: `models/${this.model}`,
                    content: {
                        parts: [{ text }],
                    },
                }),
            );

            const embedding = response.data?.embedding?.values;

            if (!embedding || !Array.isArray(embedding)) {
                throw new Error('Invalid embedding response from Gemini API');
            }

            return embedding;
        } catch (error) {
            this.logger.error(`Failed to generate embedding: ${error.message}`);
            throw error;
        }
    }

    /**
     * Generate embeddings for multiple texts in batch
     * @param texts Array of texts to embed
     * @returns Array of vector embeddings
     */
    async generateEmbeddings(texts: string[]): Promise<number[][]> {
        const embeddings: number[][] = [];

        for (const text of texts) {
            const embedding = await this.generateEmbedding(text);
            embeddings.push(embedding);

            // Rate limiting: wait 100ms between requests
            await new Promise(resolve => setTimeout(resolve, 100));
        }

        return embeddings;
    }
}
