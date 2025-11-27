import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { ConfigModule } from '@nestjs/config';
import { RagController } from './rag.controller';
import { RagService } from './rag.service';
import { QdrantService } from './qdrant.service';
import { EmbeddingsService } from './embeddings.service';
import { DocumentIndexerService } from './document-indexer.service';

@Module({
    imports: [HttpModule, ConfigModule],
    controllers: [RagController],
    providers: [
        RagService,
        QdrantService,
        EmbeddingsService,
        DocumentIndexerService,
    ],
    exports: [RagService, DocumentIndexerService],
})
export class RagModule { }
