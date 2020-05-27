import { Injectable } from '@angular/core';
import { BehaviorSubject, Subscription, Observable } from 'rxjs';
import { distinctUntilChanged, debounceTime, take } from 'rxjs/operators';

export type Key = string | object | symbol;

export interface IGetLoadingOptions {
  key?: Key;
}

export interface IUpdateLoadingOptions {
  key?: Key | Key[];
}

@Injectable({
  providedIn: 'root',
})
export class IsLoadingService {
  protected defaultKey = 'default';

  // provides an observable indicating if a particular key is loading
  private loadingSubjects = new Map<Key, BehaviorSubject<boolean>>();

  // tracks how many "things" are loading for each key
  private loadingStacks = new Map<
    unknown,
    (true | Subscription | Promise<unknown>)[]
  >();

  // tracks which keys are being watched so that unused keys
  // can be deleted/garbage collected.
  private loadingKeyIndex = new Map<Key, number>();

  constructor() {}

  /**
   * Used to determine if something is loading or not.
   *
   * When called without arguments, returns the default *isLoading*
   * observable for your app. When called with an options object
   * containing a `key` property, returns the *isLoading* observable
   * corresponding to that key.
   *
   * Internally, *isLoading* observables are `BehaviorSubject`s, so
   * they will return values immediately upon subscription.
   *
   * When called, this method creates a new observable and returns it.
   * This means that you should not use this method directly in an Angular
   * template because each time the method is called it will look
   * (to Angular change detection) like the value has changed. To make
   * subscribing in templates easier, check out the `IsLoadingPipe`.
   * Alternatively, store the observable returned from this method in
   * a variable on your component and use that variable inside your
   * template.
   *
   * Example:
   *
   * ```ts
   *  class MyCustomComponent implements OnInit {
   *    variableForUseInTemplate: Observable<boolean>;
   *
   *    constructor(private loadingService: IsLoadingService) {}
   *
   *    ngOnInit() {
   *      this.variableForUseInTemplate =
   *        this.loadingService.isLoading$({key: 'button'});
   *
   *      this.loadingService.isLoading$().subscribe(value => {
   *        // ... do stuff
   *      });
   *
   *      this.loadingService
   *        .isLoading$({key: MyCustomComponent})
   *        .subscribe(value => {
   *          // ... do stuff
   *        });
   *    }
   *  }
   * ```
   *
   * @param args.key optionally specify the key to subscribe to
   */
  isLoading$(args: IGetLoadingOptions = {}): Observable<boolean> {
    const keys = this.normalizeKeys(args.key);

    return new Observable<boolean>(observer => {
      // this function will called each time this
      // Observable is subscribed to.
      this.indexKeys(keys);

      const subscription = this.loadingSubjects
        .get(keys[0])!
        .pipe(
          distinctUntilChanged(),
          debounceTime(10),
          distinctUntilChanged(),
        )
        .subscribe(observer);

      // the return value is the teardown function,
      // which will be invoked when the new
      // Observable is unsubscribed from.
      return () => {
        subscription.unsubscribe();
        keys.forEach(key => this.deIndexKey(key));
      };
    });
  }

  /**
   * Same as `isLoading$()` except a boolean is returned,
   * rather than an observable.
   *
   * @param args.key optionally specify the key to check
   */
  isLoading(args: IGetLoadingOptions = {}): boolean {
    const key = this.normalizeKeys(args.key)[0];
    const obs = this.loadingSubjects.get(key);

    return (obs && obs.value) || false;
  }

  /**
   * Used to indicate that *something* has started loading.
   *
   * Optionally, a key or keys can be passed to track the loading
   * of different things.
   *
   * You can pass a `Subscription`, `Promise`, or `Observable`
   * argument, or you can call `add()` without arguments. If
   * this method is called with a `Subscription`, `Promise`,
   * or `Observable` argument, this method returns that argument.
   * This is to make it easier for you to chain off of `add()`.
   *
   * Example: `await isLoadingService.add(promise);`
   *
   * Options:
   *
   * - If called without arguments, the `"default"` key is
   *   marked as loading. It will remain loading until you
   *   manually call `remove()` once. If you call `add()`
   *   twice without arguments, you will need to call
   *   `remove()` twice without arguments for loading to
   *   stop. Etc.
   * - If called with a `Subscription` or `Promise`
   *   argument, the appropriate key is marked as loading
   *   until the `Subscription` or `Promise` resolves, at
   *   which point it is automatically marked as no longer
   *   loading. There is no need to call `remove()` in this
   *   scenerio.
   * - If called with an `Observable` argument, the
   *   appropriate key is marked as loading until the
   *   next emission of the `Observable`, at which point
   *   IsLoadingService will unsubscribe from the
   *   observable and mark the key as no longer loading.
   *
   * Finally, as previously noted the key option allows you
   * to track the loading of different things seperately.
   * Any truthy value can be used as a key. The key option
   * for `add()` is intended to be used in conjunction with
   * the `key` option for `isLoading$()` and `remove()`. If
   * you pass multiple keys to `add()`, each key will be
   * marked as loading.
   *
   * Example:
   *
   * ```ts
   *  class MyCustomComponent implements OnInit, AfterViewInit {
   *    constructor(
   *      private loadingService: IsLoadingService,
   *      private myCustomDataService: MyCustomDataService,
   *    ) {}
   *
   *    ngOnInit() {
   *      const subscription = this.myCustomDataService.getData().subscribe();
   *
   *      // Note, we don't need to call remove() when calling
   *      // add() with a subscription
   *      this.loadingService.add(subscription, {
   *        key: 'getting-data'
   *      });
   *
   *      // Here we mark `MyCustomComponent` as well as the "default" key
   *      // as loading, and then mark them as no longer loading in
   *      // ngAfterViewInit()
   *      this.loadingService.add({key: [MyCustomComponent, 'default']});
   *    }
   *
   *    ngAfterViewInit() {
   *      this.loadingService.remove({key: [MyCustomComponent, 'default']})
   *    }
   *
   *    async submit(data: any) {
   *      // here we take advantage of the fact that `add()` returns the
   *      // Promise passed to it.
   *      await this.loadingService.add(
   *        this.myCustomDataService.updateData(data),
   *        { key: 'button' }
   *      )
   *
   *      // do stuff...
   *    }
   *  }
   * ```
   *
   * @return If called with a `Subscription`, `Promise` or `Observable`,
   *         the Subscription/Promise/Observable is returned.
   *         This allows code like `await this.isLoadingService.add(promise)`.
   */
  add(): void;
  add(options: IUpdateLoadingOptions): void;
  add<T extends Subscription | Promise<unknown> | Observable<unknown>>(
    sub: T,
    options?: IUpdateLoadingOptions,
  ): T;
  add(
    first?: Subscription | Promise<unknown> | IUpdateLoadingOptions,
    second?: IUpdateLoadingOptions,
  ) {
    let keyParam: Key | Key[] | undefined;
    let sub: Subscription | Promise<unknown> | undefined;

    if (first instanceof Subscription) {
      if (first.closed) return first;

      sub = first;

      first.add(() => this.remove(first, second));
    } else if (first instanceof Promise) {
      sub = first;

      // If the promise is already resolved, this executes syncronously
      first.then(
        () => this.remove(first, second),
        () => this.remove(first, second),
      );
    } else if (first instanceof Observable) {
      sub = first.pipe(take(1)).subscribe();

      if (sub.closed) return first;

      sub.add(() => this.remove(sub as Subscription, second));
    } else if (first) {
      keyParam = first.key;
    }

    if (second && second.key) {
      keyParam = second.key;
    }

    const keys = this.normalizeKeys(keyParam);

    this.indexKeys(keys);

    keys.forEach(key => {
      this.loadingStacks.get(key)!.push(sub || true);

      this.updateLoadingStatus(key);
    });

    return first instanceof Observable ? first : sub;
  }

  /**
   * Used to indicate that something has stopped loading.
   *
   * - Note: if you call `add()` with a `Subscription`,
   *   `Promise`, or `Observable` argument, you do not need
   *   to manually call `remove().
   *
   * When called without arguments, `remove()`
   * removes a loading indicator from the default
   * *isLoading* observable's stack. So long as any items
   * are in an *isLoading* observable's stack, that
   * observable will be marked as loading.
   *
   * In more advanced usage, you can call `remove()` with
   * an options object which accepts a `key` property.
   * The key allows you to track the loading of different
   * things seperately. Any truthy value can be used as a
   * key. The key option for `remove()` is intended to be
   * used in conjunction with the `key` option for
   * `isLoading$()` and `add()`. If you pass an array of
   * keys to `remove()`, then each key will be marked as
   * no longer loading.
   *
   * Example:
   *
   * ```ts
   *  class MyCustomComponent implements OnInit, AfterViewInit {
   *    constructor(private loadingService: IsLoadingService) {}
   *
   *    ngOnInit() {
   *      // Pushes a loading indicator onto the `"default"` stack
   *      this.loadingService.add()
   *    }
   *
   *    ngAfterViewInit() {
   *      // Removes a loading indicator from the default stack
   *      this.loadingService.remove()
   *    }
   *
   *    performLongAction() {
   *      // Pushes a loading indicator onto the `'long-action'`
   *      // stack
   *      this.loadingService.add({key: 'long-action'})
   *    }
   *
   *    finishLongAction() {
   *      // Removes a loading indicator from the `'long-action'`
   *      // stack
   *      this.loadingService.remove({key: 'long-action'})
   *    }
   *  }
   * ```
   *
   */
  remove(): void;
  remove(options: IUpdateLoadingOptions): void;
  remove(
    sub: Subscription | Promise<unknown>,
    options?: IUpdateLoadingOptions,
  ): void;
  remove(
    first?: Subscription | Promise<unknown> | IUpdateLoadingOptions,
    second?: IUpdateLoadingOptions,
  ) {
    let keyParam: Key | Key[] | undefined;
    let sub: Subscription | Promise<unknown> | undefined;

    if (first instanceof Subscription) {
      sub = first;
    } else if (first instanceof Promise) {
      sub = first;
    } else if (first) {
      keyParam = first.key;
    }

    if (second && second.key) {
      keyParam = second.key;
    }

    const keys = this.normalizeKeys(keyParam);

    keys.forEach(key => {
      const loadingStack = this.loadingStacks.get(key);

      // !loadingStack means that a user has called remove() needlessly
      if (!loadingStack) return;

      const index = loadingStack.indexOf(sub || true);

      if (index >= 0) {
        loadingStack.splice(index, 1);

        this.updateLoadingStatus(key);

        this.deIndexKey(key);
      }
    });
  }

  private normalizeKeys(key?: Key | Key[]): Key[] {
    if (!key) key = [this.defaultKey];
    else if (!Array.isArray(key)) key = [key];
    return key as Key[];
  }

  /**
   * `indexKeys()` along with `deIndexKeys()` helps us track which
   * keys are being watched so that unused keys can be deleted
   * / garbage collected.
   *
   * When `indexKeys()` is called with an array of keys, it means
   * that each of those keys has at least one "thing" interested
   * in it. Therefore, we need to make sure that a loadingSubject
   * and loadingStack exists for that key. We also need to index
   * the number of "things" interested in that key in the
   * `loadingKeyIndex` map.
   *
   * When `deIndexKeys()` is called with an array of keys, it
   * means that some "thing" is no longer interested in each
   * of those keys. Therefore, we need to re-index
   * the number of "things" interested in each key. For keys
   * that no longer have anything interested in them, we need
   * to delete the associated `loadingKeyIndex`, `loadingSubject`,
   * and `loadingStack`. So that the `key` can be properly
   * released for garbage collection.
   */

  private indexKeys(keys: Key[]) {
    keys.forEach(key => {
      if (this.loadingKeyIndex.has(key)) {
        const curr = this.loadingKeyIndex.get(key)!;
        this.loadingKeyIndex.set(key, curr + 1);
      } else {
        const subject = new BehaviorSubject(false);

        this.loadingKeyIndex.set(key, 1);
        this.loadingSubjects.set(key, subject);
        this.loadingStacks.set(key, []);
      }
    });
  }

  private deIndexKey(key: Key) {
    const curr = this.loadingKeyIndex.get(key)!;

    if (curr === 1) {
      this.loadingKeyIndex.delete(key);
      this.loadingSubjects.delete(key);
      this.loadingStacks.delete(key);
    } else {
      this.loadingKeyIndex.set(key, curr - 1);
    }
  }

  private updateLoadingStatus(key: Key) {
    const loadingStatus = this.loadingStacks.get(key)!.length > 0;

    this.loadingSubjects.get(key)!.next(loadingStatus);
  }
}
