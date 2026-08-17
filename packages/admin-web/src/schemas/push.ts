import { z } from 'zod'

export const pushDispatchResponseSchema = z.object({
  deliveryId: z.number().int().positive(),
  quizId: z.number().int().positive(),
  title: z.string().min(1),
  channel: z.literal('mock'),
  targetCount: z.number().int().nonnegative(),
  status: z.literal('mock_sent'),
  sentAt: z.string().min(1),
})

export const pushDeliverySchema = z.object({
  deliveryId: z.number().int().positive(),
  quizId: z.number().int().positive(),
  title: z.string().min(1),
  channel: z.string().min(1),
  targetCount: z.number().int().nonnegative(),
  status: z.string().min(1),
  errorDetail: z.string().optional(),
  sentAt: z.string().min(1),
})

export const pushDeliveryListResponseSchema = z.object({
  items: z.array(pushDeliverySchema),
  total: z.number().int().nonnegative(),
  page: z.number().int().positive(),
  perPage: z.number().int().positive(),
  totalPages: z.number().int().nonnegative(),
})
