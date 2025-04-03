import { pgTable, text, serial, integer, boolean, real, jsonb } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: text("username").notNull().unique(),
  password: text("password").notNull(),
});

export const savedLocations = pgTable("saved_locations", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  lat: real("lat").notNull(),
  lon: real("lon").notNull(),
  country: text("country").notNull(),
  state: text("state"),
  userId: integer("user_id").references(() => users.id),
  current: jsonb("current"),
});

export const insertUserSchema = createInsertSchema(users).pick({
  username: true,
  password: true,
});

export const insertLocationSchema = createInsertSchema(savedLocations).pick({
  name: true,
  lat: true,
  lon: true,
  country: true,
  state: true,
});

export type InsertUser = z.infer<typeof insertUserSchema>;
export type User = typeof users.$inferSelect;
export type InsertLocation = z.infer<typeof insertLocationSchema>;
export type SavedLocation = typeof savedLocations.$inferSelect;
