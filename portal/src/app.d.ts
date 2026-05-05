import type { User } from '$lib/types';

declare module '*.sql?raw' {
    const content: string;
    export default content;
}

declare global {
    namespace App {
        interface Locals {
            user: User | null;
        }
    }
}

export {};
