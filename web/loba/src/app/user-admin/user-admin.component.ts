import { Component, OnInit, OnChanges, Input } from '@angular/core';

import { User } from '../user';
import { UserService } from '../user.service';
import { IsLoadingService } from '../is-loading.service';

@Component({
  selector: 'app-user-admin',
  templateUrl: './user-admin.component.html',
  styleUrls: ['./user-admin.component.css']
})
export class UserAdminComponent implements OnInit, OnChanges {
  @Input() users: User[];

  constructor(
    private userService: UserService,
    private isLoadingService: IsLoadingService) { }

  ngOnInit(): void {
    this.getUsers();
  }

  ngOnChanges(): void {
    this.getUsers();
  }

  addUser(email: string): void {
    this.isLoadingService.add();
    this.userService.addUser({
      email: email,
      id: null,
      first_name: null,
      last_name: null,
      roles: null,
      avatar_url: null,
    })
      .subscribe(() => {
        this.getUsers();
        this.isLoadingService.remove();
      });
  }

  getUsers(): void {
    this.isLoadingService.add();
      this.userService.getUsers()
        .subscribe(users => {
          this.users = users;
          this.isLoadingService.remove();
        });
  }
}
