import { Method } from './method';
import { Server } from './server';
import { Site } from './site';

export interface Upstream {
  id: number;
  site: Site;
  servers: Server[];
  method: Method;
  hash: string;
  consistent: boolean;
}