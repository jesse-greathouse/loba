import { Method } from './method';
import { Server } from './server';
import { Site } from './site';
import { Certificate } from './certificate';

export interface Upstream {
  id: number;
  site: Site;
  servers: Server[];
  method: Method;
  hash: string;
  consistent: boolean;
  ssl: boolean;
  certificate: Certificate;
}