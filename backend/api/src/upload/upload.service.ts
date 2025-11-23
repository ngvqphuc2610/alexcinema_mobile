import { Injectable } from '@nestjs/common';
import { existsSync, mkdirSync } from 'fs';
import { join } from 'path';

@Injectable()
export class UploadService {
  private readonly imagesDir = join(__dirname, '..', '..', '..', '..', 'assets', 'upload', 'images');

  getImagesDir() {
    if (!existsSync(this.imagesDir)) {
      mkdirSync(this.imagesDir, { recursive: true });
    }
    return this.imagesDir;
  }
}
