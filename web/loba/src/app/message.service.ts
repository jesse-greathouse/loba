import { Injectable } from '@angular/core';

import { Message } from './message';

@Injectable({
  providedIn: 'root'
})

export class MessageService {

  messages: Message[] = [];

  constructor() { }

  add(text: string, level: string|false, header: string = null) {
    if (!level) level = 'info';
    const message : Message = {text, level, header}
    this.messages.unshift(message);
  }

  clear() {
    this.messages = [];
  }
}
