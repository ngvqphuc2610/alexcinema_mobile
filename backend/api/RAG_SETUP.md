# RAG (Retrieval-Augmented Generation) Setup

## Tổng quan

RAG (Retrieval-Augmented Generation) giúp chatbot AI trả lời chính xác hơn bằng cách:
1. Tìm kiếm thông tin liên quan từ database (movies, showtimes, promotions)
2. Inject context vào prompt của Gemini
3. Gemini trả lời dựa trên dữ liệu thực tế thay vì bịa đặt

## Kiến trúc

```
User Query → Gemini Embedding API → Vector Search (Qdrant) 
          → Retrieve Top-K Docs → Augmented Prompt → Gemini LLM → Response
```

## Setup Qdrant Vector Database

### 1. Start Qdrant với Docker

```powershell
cd backend/api
docker-compose -f docker-compose.qdrant.yml up -d
```

Hoặc sử dụng script:
```powershell
.\scripts\start-qdrant.ps1
```

### 2. Verify Qdrant đang chạy

Truy cập: http://localhost:6333/dashboard

API endpoint: http://localhost:6333

### 3. Index dữ liệu

Sau khi backend API đã chạy (`npm run start:dev`):

```powershell
# Index tất cả dữ liệu
curl -X POST http://localhost:3000/api/rag/index/all

# Hoặc index từng loại
curl -X POST http://localhost:3000/api/rag/index/movies
curl -X POST http://localhost:3000/api/rag/index/showtimes
curl -X POST http://localhost:3000/api/rag/index/promotions
```

## Environment Variables

Thêm vào `backend/api/.env`:
```env
GEMINI_API_KEY=your_gemini_api_key
QDRANT_URL=http://localhost:6333
```

## API Endpoints

### Search với RAG
```http
POST /api/rag/search
Content-Type: application/json

{
  "query": "phim hành động nào đang chiếu?",
  "limit": 3
}
```

Response:
```json
{
  "success": true,
  "data": {
    "context": "=== THÔNG TIN PHIM ===\nTên phim: Avengers...",
    "sources": [
      {
        "type": "movie",
        "title": "Avengers: Endgame",
        "score": 0.89,
        "data": {...}
      }
    ]
  }
}
```

### Index Data
```http
POST /api/rag/index/all
POST /api/rag/index/movies
POST /api/rag/index/showtimes
POST /api/rag/index/promotions
```

## Cách hoạt động trong Flutter App

1. User nhập câu hỏi: "Phim Avengers chiếu lúc mấy giờ?"
2. `GeminiService` gọi `RagService.search()` để tìm context
3. `RagService` gọi backend `/rag/search` endpoint
4. Backend:
   - Generate embedding từ query
   - Search Qdrant vector DB
   - Trả về top-K relevant documents
5. `GeminiService` inject context vào prompt:
   ```
   THÔNG TIN TỪ HỆ THỐNG:
   === LỊCH CHIẾU ===
   Phim: Avengers Endgame
   Giờ chiếu: 19:00, 21:30
   ...
   
   CÂU HỎI NGƯỜI DÙNG: Phim Avengers chiếu lúc mấy giờ?
   ```
6. Gemini trả lời dựa trên context thực tế

## Collections trong Qdrant

- **movies**: Thông tin phim (title, description, genre, cast...)
- **showtimes**: Lịch chiếu (movie, cinema, time, price...)
- **promotions**: Khuyến mãi (title, description, discount...)
- **faqs**: Câu hỏi thường gặp (reserved for future)

## Re-indexing

Khi có dữ liệu mới (phim mới, suất chiếu mới):

```bash
# Có thể tạo cron job hoặc trigger sau khi update DB
curl -X POST http://localhost:3000/api/rag/index/movies
```

Hoặc index tự động sau khi create/update entities (sử dụng Prisma hooks).

## Monitoring

- Qdrant Dashboard: http://localhost:6333/dashboard
- Check collections:
  ```bash
  curl http://localhost:6333/collections
  ```
- View collection info:
  ```bash
  curl http://localhost:6333/collections/movies
  ```

## Performance Tips

1. **Batch indexing**: Index theo batch thay vì từng document
2. **Rate limiting**: Gemini Embedding API có rate limit, thêm delay 100ms giữa các requests
3. **Caching**: Cache frequent queries
4. **Incremental indexing**: Chỉ index data mới thay vì re-index tất cả

## Troubleshooting

### Qdrant không start
```powershell
docker ps  # Check containers
docker logs alexcinema-qdrant  # Check logs
```

### Embedding API errors
- Kiểm tra GEMINI_API_KEY trong .env
- Check quota: https://aistudio.google.com/app/apikey

### Search không trả về kết quả
- Verify collections đã được tạo: `curl http://localhost:6333/collections`
- Check data đã được index: `curl http://localhost:6333/collections/movies`
- Thử re-index: `curl -X POST http://localhost:3000/api/rag/index/all`

## Next Steps

1. ✅ Setup Qdrant và index data
2. ✅ Test RAG search từ backend
3. ✅ Tích hợp vào Flutter app
4. 🔄 Test end-to-end flow
5. ⏳ Optimize performance và caching
6. ⏳ Add automatic re-indexing triggers
