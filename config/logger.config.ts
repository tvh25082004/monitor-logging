// Config cho NestJS Logger với Morgan
import { WinstonModule } from 'nest-winston';
import * as winston from 'winston';
import * as DailyRotateFile from 'winston-daily-rotate-file';
import { format } from 'winston';

export const loggerConfig = {
  logger: WinstonModule.createLogger({
    format: format.combine(
      format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
      format.errors({ stack: true }),
      format.splat(),
      format.json()
    ),
    transports: [
      // Console transport
      new winston.transports.Console({
        format: format.combine(
          format.colorize(),
          format.printf(
            (info) =>
              `${info.timestamp} [${info.level}]: ${info.message} ${
                info.stack ? '\n' + info.stack : ''
              }`
          )
        ),
      }),
      // File transport - combined logs
      new DailyRotateFile({
        filename: 'app-logs/%DATE%.log',
        datePattern: 'YYYY-MM-DD',
        maxSize: '20m',
        maxFiles: '14d',
        format: format.combine(
          format.timestamp(),
          format.json()
        ),
      }),
      // File transport - error logs
      new DailyRotateFile({
        filename: 'app-logs/%DATE%-error.log',
        datePattern: 'YYYY-MM-DD',
        level: 'error',
        maxSize: '20m',
        maxFiles: '14d',
        format: format.combine(
          format.timestamp(),
          format.json()
        ),
      }),
    ],
  }),
};

// Morgan configuration for HTTP requests
export const morganConfig = {
  format: 'combined',
  options: {
    stream: {
      write: (message: string) => {
        // Write to winston logger
        const logger = WinstonModule.createLogger(loggerConfig.logger);
        logger.info(message.trim());
      },
    },
  },
};

