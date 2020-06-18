import { User } from './user';

export interface Token {
  id: number;
  provider: string;
  created_at: number;
  ttl: number;
  user: User;
  token: string;
}