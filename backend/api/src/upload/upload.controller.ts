import {
  BadRequestException,
  Controller,
  Post,
  Req,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import type { Request } from 'express';
import { memoryStorage } from 'multer';
import { extname, join } from 'path';
import { promises as fs } from 'fs';
import { UploadService } from './upload.service';

const randomSuffix = () => `${Date.now()}-${Math.round(Math.random() * 1e9)}`;

@Controller('upload')
export class UploadController {
  constructor(private readonly uploadService: UploadService) {}

  @Post('image')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: memoryStorage(),
      fileFilter: (_, file, cb) => {
        if (!file.mimetype.startsWith('image/')) {
          cb(new BadRequestException('Chi cho phep tai len tep anh'), false);
        } else {
          cb(null, true);
        }
      },
      limits: {
        fileSize: 5 * 1024 * 1024,
      },
    }),
  )
  async uploadImage(@UploadedFile() file: Express.Multer.File, @Req() req: Request) {
    if (!file) {
      throw new BadRequestException('Khong co tep nao duoc tai len');
    }

    const filename = `${randomSuffix()}${extname(file.originalname)}`;
    const targetDir = this.uploadService.getImagesDir();
    const filePath = join(targetDir, filename);
    await fs.writeFile(filePath, file.buffer);

    const relativePath = `/uploads/images/${filename}`;
    const url = `${req.protocol}://${req.get('host')}${relativePath}`;

    return {
      filename,
      path: relativePath,
      url,
    };
  }
}
