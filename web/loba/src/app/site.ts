import { Upstream } from './upstream';

export interface Site {
  id: number;
  domain: string;
  active: boolean;
  upstream: Upstream;
}