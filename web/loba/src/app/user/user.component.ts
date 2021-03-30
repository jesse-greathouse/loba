import { Component, Input, OnInit, OnChanges} from '@angular/core';

import { Role } from '../role';
import { User } from '../user';
import { IsLoadingService } from '../is-loading.service';
import { UserService } from '../user.service';

const ADMIN = "ADMIN";
const SUPER_USER = "SUPER_USER";
const USER = "USER";

@Component({
  selector: 'app-user',
  templateUrl: './user.component.html',
  styleUrls: ['./user.component.css']
})
export class UserComponent implements OnInit, OnChanges {
  @Input() user: User;
  @Input() role: string;
  roles: string[] = [ADMIN, SUPER_USER, USER]

  constructor(
    private isLoadingService: IsLoadingService,
    private userService: UserService) { }

  ngOnInit(): void {
    this.resetRole();
  }

  ngOnChanges(): void {
  }

  removeConfirm(): void {
  }

  roleChange($event): void {
    this.save();
  }

  focusOut(): void {
    this.save();
  }

  save(): void {
    this.isLoadingService.add();
    this.user.roles = [this.role]
    this.userService.updateUser(this.user)
      .subscribe(user => {
        this.user = user;
        this.resetRole();
        this.isLoadingService.remove();
      });
  }

  resetRole(): void {
    if (this.user.roles.length > 0) {
      if (this.user.roles.indexOf(ADMIN) !== -1) {
        this.role = this.roles[0];
      }

      if (this.user.roles.indexOf(SUPER_USER) !== -1) {
        this.role = this.roles[1];
      }

      if (this.user.roles.indexOf(USER) !== -1) {
        this.role = this.roles[2];
      }
    }
  }

}
