import { Logger, ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const port = process.env.PORT || 3000;

  // debug: show env values backend đang nhận
  console.log('>>> Backend ENV check:', {
    API_URL: process.env.API_URL,
    NODE_ENV: process.env.NODE_ENV,
    PORT: process.env.PORT,
    // thêm các key khác bạn quan tâm
  });

  const configService = app.get(ConfigService);
  const logger = new Logger('Bootstrap');

  const globalPrefix = configService.get<string>('APP_GLOBAL_PREFIX', 'api');
  app.setGlobalPrefix(globalPrefix);

  const corsOrigins = configService.get<string>('CORS_ORIGIN');
  app.enableCors({
    origin: corsOrigins ? corsOrigins.split(',').map((origin) => origin.trim()) : true,
    credentials: true,
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  const swaggerEnabled = configService.get<string>('SWAGGER_ENABLED', 'true') !== 'false';
  if (swaggerEnabled) {
    const swaggerConfig = new DocumentBuilder()
      .setTitle(configService.get<string>('SWAGGER_TITLE', 'Alex Cinema API'))
      .setDescription(configService.get<string>('SWAGGER_DESCRIPTION', 'REST API for Alex Cinema platform'))
      .setVersion(configService.get<string>('SWAGGER_VERSION', '1.0'))
      .addBearerAuth()
      .build();

    const document = SwaggerModule.createDocument(app, swaggerConfig);
    const swaggerPath = configService.get<string>('SWAGGER_PATH', 'docs');
    SwaggerModule.setup(swaggerPath, app, document, {
      swaggerOptions: {
        persistAuthorization: true,
      },
    });
  }

  await app.listen(port);

  const baseUrl = await app.getUrl();
  logger.log(`Application running at ${baseUrl}/${globalPrefix}`);
  if (swaggerEnabled) {
    logger.log(`Swagger documentation available at ${baseUrl}/${configService.get<string>('SWAGGER_PATH', 'docs')}`);
  }
}

bootstrap();

