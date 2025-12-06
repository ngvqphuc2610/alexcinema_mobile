import {
    WebSocketGateway,
    WebSocketServer,
    SubscribeMessage,
    ConnectedSocket,
    MessageBody,
    OnGatewayConnection,
    OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';
import { SeatLocksService } from './seat_locks.service';

@WebSocketGateway({
    cors: {
        origin: '*', // Configure properly for production
        credentials: true,
    },
    namespace: '/seats',
})
export class SeatLocksGateway
    implements OnGatewayConnection, OnGatewayDisconnect {
    @WebSocketServer()
    server: Server;

    private readonly logger = new Logger(SeatLocksGateway.name);

    constructor(private readonly seatLocksService: SeatLocksService) { }

    handleConnection(client: Socket) {
        this.logger.log(`🔌 Client connected: ${client.id}`);
    }

    async handleDisconnect(client: Socket) {
        this.logger.log(`🔌 Client disconnected: ${client.id}`);

        try {
            // Get all locks for this session before releasing
            const releasedSeats = await this.seatLocksService.releaseAllBySession(
                client.id,
            );

            // Notify other clients about released seats
            for (const seat of releasedSeats) {
                this.server.to(`showtime-${seat.showtimeId}`).emit('seatUnlocked', {
                    seatId: seat.seatId,
                    sessionId: client.id,
                });
            }

            this.logger.log(`🔓 Released ${releasedSeats.length} seats for client ${client.id}`);
        } catch (error) {
            this.logger.error(`Error releasing seats on disconnect: ${error.message}`);
        }
    }

    @SubscribeMessage('joinShowtime')
    async handleJoinShowtime(
        @ConnectedSocket() client: Socket,
        @MessageBody() data: { showtimeId: number },
    ) {
        try {
            const { showtimeId } = data;
            const roomName = `showtime-${showtimeId}`;

            // Join the showtime room
            await client.join(roomName);
            this.logger.log(`📺 Client ${client.id} joined ${roomName}`);

            // Get currently locked seats for this showtime
            const lockedSeats = await this.seatLocksService.getLockedSeats(
                showtimeId,
            );

            this.logger.log(`📋 Sending ${lockedSeats.length} locked seats to client ${client.id}`);

            return {
                success: true,
                lockedSeats: lockedSeats.map((seat) => ({
                    seatId: seat.seatId,
                    sessionId: seat.sessionId,
                    expiresAt: seat.expiresAt,
                })),
            };
        } catch (error) {
            this.logger.error(`Error joining showtime: ${error.message}`);
            return {
                success: false,
                error: error.message,
            };
        }
    }

    @SubscribeMessage('lockSeat')
    async handleLockSeat(
        @ConnectedSocket() client: Socket,
        @MessageBody() data: { showtimeId: number; seatId: number },
    ) {
        try {
            const { showtimeId, seatId } = data;

            this.logger.log(`🔒 Attempting to lock seat ${seatId} for showtime ${showtimeId} by ${client.id}`);

            const lock = await this.seatLocksService.lockSeat(
                showtimeId,
                seatId,
                client.id,
            );

            // Notify all clients in this showtime room (except sender)
            client.to(`showtime-${showtimeId}`).emit('seatLocked', {
                seatId: seatId,
                sessionId: client.id,
                expiresAt: lock.expires_at,
            });

            this.logger.log(`✅ Seat ${seatId} locked by ${client.id}`);

            return {
                success: true,
                lock: {
                    seatId: lock.id_seats,
                    expiresAt: lock.expires_at,
                },
            };
        } catch (error) {
            this.logger.warn(`❌ Failed to lock seat: ${error.message}`);
            return {
                success: false,
                error: error.message,
            };
        }
    }

    @SubscribeMessage('unlockSeat')
    async handleUnlockSeat(
        @ConnectedSocket() client: Socket,
        @MessageBody() data: { showtimeId: number; seatId: number },
    ) {
        try {
            const { showtimeId, seatId } = data;

            this.logger.log(`🔓 Attempting to unlock seat ${seatId} for showtime ${showtimeId} by ${client.id}`);

            await this.seatLocksService.unlockSeat(showtimeId, seatId, client.id);

            // Notify all clients in this showtime room
            this.server.to(`showtime-${showtimeId}`).emit('seatUnlocked', {
                seatId: seatId,
                sessionId: client.id,
            });

            this.logger.log(`✅ Seat ${seatId} unlocked by ${client.id}`);

            return { success: true };
        } catch (error) {
            this.logger.warn(`❌ Failed to unlock seat: ${error.message}`);
            return {
                success: false,
                error: error.message,
            };
        }
    }

    @SubscribeMessage('getLockedSeats')
    async handleGetLockedSeats(
        @ConnectedSocket() client: Socket,
        @MessageBody() data: { showtimeId: number },
    ) {
        try {
            const lockedSeats = await this.seatLocksService.getLockedSeats(
                data.showtimeId,
            );

            return {
                success: true,
                lockedSeats: lockedSeats.map((seat) => ({
                    seatId: seat.seatId,
                    sessionId: seat.sessionId,
                    expiresAt: seat.expiresAt,
                })),
            };
        } catch (error) {
            this.logger.error(`Error getting locked seats: ${error.message}`);
            return {
                success: false,
                error: error.message,
            };
        }
    }
}
