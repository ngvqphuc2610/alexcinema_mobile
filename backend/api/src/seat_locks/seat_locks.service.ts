import { Injectable, ConflictException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Cron, CronExpression } from '@nestjs/schedule';

@Injectable()
export class SeatLocksService {
    private readonly logger = new Logger(SeatLocksService.name);

    constructor(private readonly prisma: PrismaService) { }

    /**
     * Lock a seat for a specific showtime
     * @param showtimeId ID of the showtime
     * @param seatId ID of the seat to lock
     * @param sessionId Session/Socket ID of the user
     * @returns Created/Updated lock
     */
    async lockSeat(showtimeId: number, seatId: number, sessionId: string) {
        // Check if seat is already locked by someone else
        const existing = await this.prisma.seat_locks.findFirst({
            where: {
                id_showtime: showtimeId,
                id_seats: seatId,
                expires_at: {
                    gte: new Date(),
                },
            },
        });

        if (existing && existing.session_id !== sessionId) {
            throw new ConflictException(
                `Seat ${seatId} is already locked by another user`,
            );
        }

        // Lock expires in 5 minutes (matching booking timeout)
        const expiresAt = new Date();
        expiresAt.setMinutes(expiresAt.getMinutes() + 10);

        this.logger.debug(
            `Locking seat ${seatId} for showtime ${showtimeId} until ${expiresAt.toISOString()}`,
        );

        // Upsert to handle both create and refresh scenarios
        return this.prisma.seat_locks.upsert({
            where: {
                id_showtime_id_seats: {
                    id_showtime: showtimeId,
                    id_seats: seatId,
                },
            },
            update: {
                expires_at: expiresAt,
                session_id: sessionId,
            },
            create: {
                id_showtime: showtimeId,
                id_seats: seatId,
                session_id: sessionId,
                expires_at: expiresAt,
            },
        });
    }

    /**
     * Unlock a seat
     * @param showtimeId ID of the showtime
     * @param seatId ID of the seat to unlock
     * @param sessionId Session ID (only owner can unlock)
     */
    async unlockSeat(showtimeId: number, seatId: number, sessionId: string) {
        this.logger.debug(
            `Unlocking seat ${seatId} for showtime ${showtimeId} by session ${sessionId}`,
        );

        const result = await this.prisma.seat_locks.deleteMany({
            where: {
                id_showtime: showtimeId,
                id_seats: seatId,
                session_id: sessionId,
            },
        });

        return result.count > 0;
    }

    /**
     * Release all locks held by a specific session
     * Used when user disconnects
     * @param sessionId Session/Socket ID
     * @returns List of released seats
     */
    async releaseAllBySession(sessionId: string) {
        // First, get all locks for this session
        const locks = await this.prisma.seat_locks.findMany({
            where: { session_id: sessionId },
            select: {
                id_showtime: true,
                id_seats: true,
            },
        });

        // Delete all locks
        await this.prisma.seat_locks.deleteMany({
            where: { session_id: sessionId },
        });

        this.logger.log(`Released ${locks.length} locks for session ${sessionId}`);

        // Return info about released seats for broadcasting
        return locks.map((lock) => ({
            showtimeId: lock.id_showtime,
            seatId: lock.id_seats,
        }));
    }

    /**
     * Get all currently locked seats for a showtime
     * @param showtimeId ID of the showtime
     * @returns Array of locked seats
     */
    async getLockedSeats(showtimeId: number) {
        const locks = await this.prisma.seat_locks.findMany({
            where: {
                id_showtime: showtimeId,
                expires_at: {
                    gte: new Date(),
                },
            },
            select: {
                id_seats: true,
                session_id: true,
                expires_at: true,
            },
        });

        return locks.map((lock) => ({
            seatId: lock.id_seats,
            sessionId: lock.session_id,
            expiresAt: lock.expires_at,
        }));
    }

    /**
     * Get locks for a specific session
     * @param sessionId Session/Socket ID
     */
    async getSessionLocks(sessionId: string) {
        const locks = await this.prisma.seat_locks.findMany({
            where: {
                session_id: sessionId,
                expires_at: {
                    gte: new Date(),
                },
            },
            select: {
                id_showtime: true,
                id_seats: true,
                expires_at: true,
            },
        });

        return locks.map((lock) => ({
            showtimeId: lock.id_showtime,
            seatId: lock.id_seats,
            expiresAt: lock.expires_at,
        }));
    }

    /**
     * Cleanup expired locks
     * Runs every minute via cron job
     */
    @Cron(CronExpression.EVERY_MINUTE)
    async cleanupExpiredLocks() {
        try {
            const result = await this.prisma.seat_locks.deleteMany({
                where: {
                    expires_at: {
                        lt: new Date(),
                    },
                },
            });

            if (result.count > 0) {
                this.logger.log(`🧹 Cleaned up ${result.count} expired seat locks`);
            }
        } catch (error) {
            this.logger.error(`Error cleaning up expired locks: ${error.message}`);
        }
    }

    /**
     * Check if a seat is currently locked
     * @param showtimeId ID of the showtime
     * @param seatId ID of the seat
     * @returns Lock info if locked, null otherwise
     */
    async isLocked(showtimeId: number, seatId: number) {
        const lock = await this.prisma.seat_locks.findFirst({
            where: {
                id_showtime: showtimeId,
                id_seats: seatId,
                expires_at: {
                    gte: new Date(),
                },
            },
        });

        if (!lock) {
            return null;
        }

        return {
            sessionId: lock.session_id,
            expiresAt: lock.expires_at,
        };
    }
}
