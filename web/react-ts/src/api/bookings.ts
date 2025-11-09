import type { Booking, PaginatedResource } from '../types';
import apiClient from './client';

export interface BookingQueryParams extends Record<string, unknown> {
  page?: number;
  limit?: number;
  userId?: number;
  memberId?: number;
  showtimeId?: number;
  staffId?: number;
  promotionId?: number;
  paymentStatus?: string;
  bookingStatus?: string;
  bookingCode?: string;
}

export interface BookingPayload extends Record<string, unknown> {
  idUsers?: number;
  idMember?: number;
  idShowtime?: number;
  idStaff?: number;
  idPromotions?: number;
  bookingDate?: string;
  totalAmount: number;
  paymentStatus?: string;
  bookingStatus?: string;
  bookingCode?: string;
}

export interface UpdateBookingPayload extends Partial<BookingPayload> {}

const removeEmpty = <T extends Record<string, unknown>>(payload: T) => {
  const result: Record<string, unknown> = {};
  Object.entries(payload).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== '') {
      result[key] = value;
    }
  });
  return result;
};

export const fetchBookings = async (params: BookingQueryParams = {}): Promise<PaginatedResource<Booking>> => {
  const { data } = await apiClient.get<PaginatedResource<Booking>>('/bookings', { params: removeEmpty(params) });
  return data;
};

export const fetchBooking = async (id: number): Promise<Booking> => {
  const { data } = await apiClient.get<Booking>(`/bookings/${id}`);
  return data;
};

export const createBooking = async (payload: BookingPayload): Promise<Booking> => {
  const { data } = await apiClient.post<Booking>('/bookings', removeEmpty(payload));
  return data;
};

export const updateBooking = async (id: number, payload: UpdateBookingPayload): Promise<Booking> => {
  const { data } = await apiClient.patch<Booking>(`/bookings/${id}`, removeEmpty(payload));
  return data;
};

export const deleteBooking = async (id: number): Promise<void> => {
  await apiClient.delete(`/bookings/${id}`);
};
