import { z } from "zod"

export const PASSWORD_HINT = "حداقل ۸ کاراکتر و شامل حداقل یک حرف و یک عدد"
export const PHONE_HINT = "شمارهٔ موبایل را با صفر ابتدا وارد کنید؛ مثال: ۰۹۱۲۳۴۵۶۷۸۹"

export const passwordSchema = z
  .string()
  .min(8, "رمز عبور باید حداقل ۸ کاراکتر باشد")
  .regex(/[A-Za-z]/, "رمز عبور باید حداقل شامل یک حرف باشد")
  .regex(/[0-9]/, "رمز عبور باید حداقل شامل یک عدد باشد")

export const phoneSchema = z
  .string()
  .min(10, "شماره موبایل معتبر وارد کنید")
  .regex(/^0\d{9,10}$/, "شماره موبایل معتبر وارد کنید (مثال: ۰۹۱۲۳۴۵۶۷۸۹)")

export const otpCodeSchema = z
  .string()
  .length(6, "کد باید ۶ رقم باشد")
  .regex(/^\d{6}$/, "کد باید فقط شامل عدد باشد")
