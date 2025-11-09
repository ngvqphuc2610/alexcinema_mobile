export interface ApiMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface ApiListResponse<T> {
  items: T[];
  meta: ApiMeta;
}

export interface AuthUser {
  id_users: number;
  username: string;
  email: string;
  full_name: string;
  phone_number?: string | null;
  date_of_birth?: string | null;
  gender?: string | null;
  address?: string | null;
  profile_image?: string | null;
  created_at: string;
  updated_at: string;
  role: string;
  status: string;
  member?: unknown;
}

export interface AuthResponse {
  accessToken: string;
  expiresIn: string;
  user: AuthUser;
}

export interface User extends AuthUser {}

export type MovieStatus = 'coming soon' | 'now showing' | 'expired';

export interface Movie {
  id_movie: number;
  title: string;
  original_title?: string | null;
  director?: string | null;
  actors?: string | null;
  duration: number;
  release_date: string;
  end_date?: string | null;
  language?: string | null;
  subtitle?: string | null;
  country?: string | null;
  description?: string | null;
  poster_image?: string | null;
  banner_image?: string | null;
  trailer_url?: string | null;
  age_restriction?: string | null;
  status: MovieStatus;
}

export interface Screen {
  id_screen: number;
  id_cinema?: number | null;
  screen_name: string;
  capacity: number;
  status: string;
}

export interface Showtime {
  id_showtime: number;
  id_movie?: number | null;
  id_screen?: number | null;
  show_date: string;
  start_time: string;
  end_time: string;
  format?: string | null;
  language?: string | null;
  subtitle?: string | null;
  status?: string | null;
  price: string;
  movie?: Movie | null;
  screen?: Screen | null;
}

export interface Promotion {
  id_promotions: number;
  promotion_code: string;
  title: string;
  description?: string | null;
  discount_percent: string;
  discount_amount: string;
  start_date: string;
  end_date?: string | null;
  min_purchase: string;
  max_discount?: string | null;
  usage_limit?: number | null;
  status: string;
}

export interface Booking {
  id_booking: number;
  id_users?: number | null;
  id_member?: number | null;
  id_showtime?: number | null;
  id_staff?: number | null;
  id_promotions?: number | null;
  booking_date: string;
  total_amount: string;
  payment_status: string;
  booking_status: string;
  booking_code?: string | null;
  user?: User | null;
  member?: Record<string, unknown> | null;
  showtime?: Showtime | null;
  staff?: Record<string, unknown> | null;
  promotion?: Promotion | null;
  payments?: Array<Record<string, unknown>>;
  details?: Array<Record<string, unknown>>;
}

export type PaginatedResource<T> = ApiListResponse<T>;

export interface PaginationParams {
  page?: number;
  limit?: number;
  search?: string;
}

