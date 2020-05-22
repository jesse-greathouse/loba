export interface Server {
    id: number;
    host: string;
    weight: boolean;
    fail_timeout: number;
    backup: number;
    max_fails: number;
}