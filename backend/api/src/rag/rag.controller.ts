import { Controller, Post, Get, Body, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsInt, Min } from 'class-validator';
import { RagService } from './rag.service';
import { DocumentIndexerService } from './document-indexer.service';

class SearchDto {
    @ApiProperty({ description: 'Search query', example: 'phim gì đang chiếu' })
    @IsString()
    query: string;

    @ApiProperty({ description: 'Maximum number of results', example: 3, required: false })
    @IsOptional()
    @IsInt()
    @Min(1)
    limit?: number;
}

@ApiTags('RAG')
@Controller('rag')
export class RagController {
    constructor(
        private readonly ragService: RagService,
        private readonly indexer: DocumentIndexerService,
    ) { }

    @Post('search')
    @ApiOperation({ summary: 'Search for relevant context using RAG' })
    @ApiResponse({ status: 200, description: 'Search results with context' })
    async search(@Body() dto: SearchDto) {
        const result = await this.ragService.search(dto.query, dto.limit || 3);
        return {
            success: true,
            data: result,
        };
    }

    @Post('hybrid-search')
    @ApiOperation({ summary: 'Hybrid search: combines vector (semantic) + keyword (exact) search' })
    @ApiResponse({ status: 200, description: 'Combined search results with better fuzzy matching' })
    async hybridSearch(@Body() dto: SearchDto) {
        const result = await this.ragService.hybridSearch(dto.query, dto.limit || 5);
        return {
            success: true,
            data: result,
        };
    }

    @Post('index/movies')
    @ApiOperation({ summary: 'Index all movies into vector database' })
    async indexMovies() {
        const count = await this.indexer.indexMovies();
        return {
            success: true,
            message: `Indexed ${count} movies`,
        };
    }

    @Post('index/showtimes')
    @ApiOperation({ summary: 'Index showtimes into vector database' })
    async indexShowtimes() {
        const count = await this.indexer.indexShowtimes();
        return {
            success: true,
            message: `Indexed ${count} showtimes`,
        };
    }

    @Post('index/promotions')
    @ApiOperation({ summary: 'Index promotions into vector database' })
    async indexPromotions() {
        const count = await this.indexer.indexPromotions();
        return {
            success: true,
            message: `Indexed ${count} promotions`,
        };
    }

    @Post('index/cinemas')
    @ApiOperation({ summary: 'Index cinemas into vector database' })
    async indexCinemas() {
        const count = await this.indexer.indexCinemas();
        return {
            success: true,
            message: `Indexed ${count} cinemas`,
        };
    }

    @Post('index/all')
    @ApiOperation({ summary: 'Index all data into vector database' })
    async indexAll() {
        const result = await this.indexer.indexAll();
        return {
            success: true,
            message: 'Indexing completed',
            data: result,
        };
    }
}
