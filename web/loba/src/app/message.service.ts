import { Injectable } from '@angular/core';

import {
  MatSnackBar,
  MatSnackBarHorizontalPosition,
  MatSnackBarVerticalPosition,
  MatSnackBarConfig,
} from '@angular/material/snack-bar';

import { Message } from './message';

@Injectable({
  providedIn: 'root'
})

export class MessageService {

  messages: Message[] = [];
  horizontalPosition: MatSnackBarHorizontalPosition = 'right';
  verticalPosition: MatSnackBarVerticalPosition = 'bottom';
  duration: number = 1500;
  messageLevelTable = {
    'info'    : ['info-snackbar'],
    'danger'  : ['danger-snackbar'],
    'warning' : ['warning-snackbar'],
    'success' : ['success-snackbar']
  };

  constructor(private _snackBar: MatSnackBar) { }

  add(text: string, level: string|false, header: string = null) {
    if (!level) level = 'info';
    const message : Message = {text, level, header}
    this.openSnackBar(message);
    this.messages.unshift(message);
  }

  clear() {
    this.messages = [];
  }

  openSnackBar(message: Message) {
    let config = new MatSnackBarConfig();
    let levels = Object.keys(this.messageLevelTable);
    let i = levels.indexOf(message.level);

    config.duration = this.duration;
    config.horizontalPosition = this.horizontalPosition;
    config.verticalPosition = this.verticalPosition;

    if (i >= 0) {
      config.panelClass = this.messageLevelTable[message.level];

      // allow the duration to be longer if it was an error
      if (message.level === 'danger') {
        config.duration = config.duration * 10;
      }
    }

    this._snackBar.open(message.text, 'close', config);
  }
}
