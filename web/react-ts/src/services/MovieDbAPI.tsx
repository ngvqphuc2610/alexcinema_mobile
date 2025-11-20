import axios from "axios";


const API_KEY = import.meta.env.VITE_TMDB_API_KEY;
const baseURL = import.meta.env.VITE_TMDB_BASE_URL;

// Cache cho genre để không phải gọi API nhiều lần
let genresCache: Record<number, string> = {};

export const MovieDbAPI = {
  // Lấy danh sách thể loại phim
  getGenres: async () => {
    try {
      if (Object.keys(genresCache).length > 0) {
        return genresCache;
      }

      const response = await axios.get(`${baseURL}/genre/movie/list`, {
        params: {
          api_key: API_KEY,
          language: "vi-VN"
        }
      });

      const genres = response.data.genres;
      genres.forEach((genre: { id: number, name: string }) => {
        genresCache[genre.id] = genre.name;
      });

      return genresCache;
    } catch (error) {
      console.error("Lỗi khi lấy danh sách thể loại:", error);
      return {};
    }
  },
  //lấy thông tin diễn viên và đạo diễn của phim
  getMovieCredits: async (movieId: number) => {
    try {
      const response = await axios.get(`${baseURL}/movie/${movieId}/credits`, {
        params: {
          api_key: API_KEY,
          language: "vi-VN"
        }
      });

      // Trả về danh sách diễn viên chính (ví dụ: lấy top 5)
      const cast = response.data.cast
        .slice(0, 5)
        .map((actor: any) => ({
          id: actor.id,
          name: actor.name,
          character: actor.character,
          profile_path: actor.profile_path
            ? `https://image.tmdb.org/t/p/w300${actor.profile_path}`
            : "/images/no-avatar.png"
        }));

      // Trả về đạo diễn (crew có job là "Director")
      const director = response.data.crew.find((member: any) => member.job === "Director");

      return {
        director: director ? {
          id: director.id,
          name: director.name,
          profile_path: director.profile_path
            ? `https://image.tmdb.org/t/p/w300${director.profile_path}`
            : "/images/no-avatar.png"
        } : null,
        cast
      };
    } catch (error) {
      console.error(`Lỗi khi lấy diễn viên và đạo diễn phim ${movieId}:`, error);
      return {
        director: null,
        cast: []
      };
    }
  },

  // Lấy chi tiết phim
  getMovieDetails: async (movieId: number) => {
    try {
      const response = await axios.get(`${baseURL}/movie/${movieId}`, {
        params: {
          api_key: API_KEY,
          language: "vi-VN",
          append_to_response: "credits,release_dates"
        }
      });

      return response.data;
    } catch (error) {
      console.error(`Lỗi khi lấy chi tiết phim ${movieId}:`, error);
      return null;
    }
  },

  getNowPlayingMovies: async () => {
    try {
      // Đảm bảo genres đã được load
      await MovieDbAPI.getGenres();

      const response = await axios.get(`${baseURL}/movie/now_playing`, {
        params: {
          api_key: API_KEY,
          language: "vi-VN",
          region: "VN",
          page: 1
        }
      });

      const formattedMovies = await Promise.all(
        response.data.results.map((movie: any) => MovieDbAPI.formatMovieData(movie))
      );

      return formattedMovies;
    } catch (error) {
      console.error("Lỗi khi lấy phim đang chiếu:", error);
      throw error;
    }
  },

  getUpcomingMovies: async () => {
    try {
      // Đảm bảo genres đã được load
      await MovieDbAPI.getGenres();

      const response = await axios.get(`${baseURL}/movie/upcoming`, {
        params: {
          api_key: API_KEY,
          language: "vi-VN",
          region: "VN",
          page: 1
        }
      });

      const formattedMovies = await Promise.all(
        response.data.results.map((movie: any) => MovieDbAPI.formatMovieData(movie))
      );

      return formattedMovies;
    } catch (error) {
      console.error("Lỗi khi lấy phim sắp chiếu:", error);
      throw error;
    }
  },

  getPopularMovies: async () => {
    try {
      // Đảm bảo genres đã được load
      await MovieDbAPI.getGenres();

      const response = await axios.get(`${baseURL}/movie/popular`, {
        params: {
          api_key: API_KEY,
          language: "vi-VN",
          region: "VN",
          page: 1
        }
      });

      const formattedMovies = await Promise.all(
        response.data.results.map((movie: any) => MovieDbAPI.formatMovieData(movie))
      );

      return formattedMovies;
    } catch (error) {
      console.error("Lỗi khi lấy phim phổ biến:", error);
      throw error;
    }
  },

  getMovieTrailer: async (movieId: number) => {
    try {
      const response = await axios.get(`${baseURL}/movie/${movieId}/videos`, {
        params: {
          api_key: API_KEY,
          language: "en-US" // Thường trailers có sẵn nhiều hơn trong tiếng Anh
        }
      });

      const trailers = response.data.results;
      // Ưu tiên trailers chính thức
      const officialTrailer = trailers.find(
        (video: any) => video.site === "YouTube" &&
          (video.type === "Trailer" || video.type === "Teaser") &&
          video.official === true
      );

      // Nếu không có trailer chính thức, tìm bất kỳ trailer nào
      const anyTrailer = trailers.find(
        (video: any) => video.site === "YouTube" &&
          (video.type === "Trailer" || video.type === "Teaser")
      );

      return officialTrailer || anyTrailer
        ? `https://www.youtube.com/watch?v=${(officialTrailer || anyTrailer).key}`
        : null;

    } catch (error) {
      console.error("Lỗi khi lấy trailer:", error);
      return null;
    }
  },

  // Hàm chuyển đổi dữ liệu từ API sang định dạng MovieProps
  formatMovieData: async (movie: {
    id: number;
    title: string;
    poster_path: string | null;
    backdrop_path: string | null;
    adult: boolean;
    genre_ids?: number[];
    overview?: string;
    release_date?: string;
    vote_average?: number;
  }) => {
    // Format genres từ id thành chuỗi
    let genreNames = "Phim";
    if (movie.genre_ids && movie.genre_ids.length > 0) {
      try {
        // Lấy tên thể loại từ cache
        genreNames = movie.genre_ids
          .map(id => genresCache[id] || "")
          .filter(name => name)
          .join(", ");

        if (!genreNames) genreNames = "Phim";
      } catch (error) {
        console.error("Lỗi khi format thể loại:", error);
        genreNames = "Phim";
      }
    }

    // Lấy thêm thông tin chi tiết phim nếu cần (runtime, countries)
    let movieDetails;
    try {
      movieDetails = await MovieDbAPI.getMovieDetails(movie.id);
    } catch (error) {
      console.error("Không thể lấy chi tiết phim:", error);
    }

    // Lấy trailer từ API
    const trailerUrl = await MovieDbAPI.getMovieTrailer(movie.id);

    // Lấy thời lượng phim từ chi tiết nếu có
    const duration = movieDetails?.runtime || 120;

    // Lấy quốc gia sản xuất
    let country = "Khác";
    if (movieDetails?.production_countries && movieDetails.production_countries.length > 0) {
      country = movieDetails.production_countries[0].name;
    }

    // Tính rating dựa trên nhiều yếu tố
    let rating = 'P';
    if (movie.adult) {
      rating = 'T18';
    } else if (movieDetails?.release_dates) {
      // Tìm thông tin rating từ certification
      const vietnamRating = movieDetails.release_dates.results.find(
        (r: any) => r.iso_3166_1 === "VN"
      );

      if (vietnamRating && vietnamRating.release_dates.length > 0) {
        const certification = vietnamRating.release_dates[0].certification;
        if (certification) {
          rating = certification;
        }
      } else {
        // Nếu không có rating VN, dùng US thay thế
        const usRating = movieDetails.release_dates.results.find(
          (r: any) => r.iso_3166_1 === "US"
        );

        if (usRating && usRating.release_dates.length > 0) {
          const certification = usRating.release_dates[0].certification;
          if (certification) {
            // Map US rating về định dạng VN
            switch (certification) {
              case "G": rating = "P"; break;
              case "PG": rating = "C13"; break;
              case "PG-13": rating = "C16"; break;
              case "R": rating = "C18"; break;
              case "NC-17": rating = "T18"; break;
              default: rating = "P";
            }
          }
        }
      }
    }

    return {
      id: movie.id.toString(),
      title: movie.title,
      poster: movie.poster_path
        ? `https://image.tmdb.org/t/p/w500${movie.poster_path}`
        : '/images/no-poster.png',
      backdrop: movie.backdrop_path
        ? `https://image.tmdb.org/t/p/original${movie.backdrop_path}`
        : null,
      rating: rating,
      genre: genreNames,
      duration: duration,
      country: country,
      language: "Phụ đề",
      format: "2D",
      trailerUrl: trailerUrl || "",
      overview: movie.overview,
      releaseDate: movie.release_date,
      voteAverage: movie.vote_average || 0
    };
  },

  searchMovies: async (query: string) => {
    if (!query.trim()) return [];

    try {
      const response = await axios.get(`${baseURL}/search/movie`, {
        params: {
          api_key: API_KEY,
          language: "vi-VN",
          query: query,
          page: 1,
          include_adult: false
        }
      });

      const formattedMovies = await Promise.all(
        response.data.results.map((movie: any) => MovieDbAPI.formatMovieData(movie))
      );

      return formattedMovies;
    } catch (error) {
      console.error("Lỗi khi tìm kiếm phim:", error);
      return [];
    }
  },

  // Phương thức để đồng bộ hóa phim với database
  syncWithDatabase: async () => {
    try {
      // Gọi API để kích hoạt đồng bộ hóa
      const response = await fetch('/api/admin/movies/sync', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error('Có lỗi khi đồng bộ phim');
      }

      return await response.json();
    } catch (error) {
      console.error("Lỗi khi đồng bộ phim với database:", error);
      throw error;
    }
  },
};
