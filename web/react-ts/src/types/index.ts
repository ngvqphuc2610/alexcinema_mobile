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

export interface Cinema {
  id_cinema: number;
  cinema_name: string;
  address: string;
  city: string;
  description?: string | null;
  image?: string | null;
  contact_number?: string | null;
  email?: string | null;
  status: string;
  _count?: {
    screens: number;
    operation_hours: number;
  };
}

export interface ScreenType {
  id_screentype: number;
  type_name: string;
  description?: string | null;
}

export interface Screen {
  id_screen: number;
  id_cinema?: number | null;
  id_screentype?: number | null;
  screen_name: string;
  capacity: number;
  status: string;
  cinema?: Cinema | null;
  screen_type?: ScreenType | null;
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

export interface Seat {
  id_seats: number;
  id_screen?: number | null;
  id_seattype?: number | null;
  seat_row: string;
  seat_number: number;
  status?: string | null;
}

export interface Membership {
  id_membership: number;
  code: string;
  title: string;
  image?: string | null;
  link?: string | null;
  description?: string | null;
  benefits?: string | null;
  criteria?: string | null;
  status: string;
}

export interface TypeMember {
  id_typemember: number;
  type_name: string;
  description?: string | null;
  priority: number;
}

export interface Member {
  id_member: number;
  id_user?: number | null;
  id_typemember?: number | null;
  id_membership?: number | null;
  points?: number | null;
  join_date?: string | null;
  status: string;
  user?: User | null;
  type_member?: TypeMember | null;
  membership?: Membership | null;
}

export interface TypeStaff {
  id_typestaff: number;
  type_name: string;
  description?: string | null;
  permission_level: number;
}

export interface Staff {
  id_staff: number;
  id_typestaff?: number | null;
  staff_name: string;
  email: string;
  phone_number?: string | null;
  address?: string | null;
  date_of_birth?: string | null;
  hire_date?: string | null;
  status?: string | null;
  profile_image?: string | null;
  type_staff?: TypeStaff | null;
}

export interface Contact {
  id_contact: number;
  id_staff?: number | null;
  name: string;
  email: string;
  subject: string;
  message: string;
  contact_date: string;
  status: string;
  reply?: string | null;
  reply_date?: string | null;
  staff?: Staff | null;
}

export interface Entertainment {
  id_entertainment: number;
  id_cinema?: number | null;
  title: string;
  description?: string | null;
  image_url?: string | null;
  start_date: string;
  end_date?: string | null;
  status?: string | null;
  views_count?: number | null;
  featured?: boolean | null;
  id_staff?: number | null;
  cinema?: Cinema | null;
  staff?: Staff | null;
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
