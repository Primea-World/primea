class Mutex {
  private locked = false;
  private waiting: (() => void)[] = [];

  lock(): Promise<void> {
    if (this.locked) {
      return new Promise<void>((resolve) => {
        this.waiting.push(resolve);
      });
    } else {
      this.locked = true;
      return Promise.resolve();
    }
  }

  unlock(): void {
    if (this.waiting.length > 0) {
      const next = this.waiting.shift();
      if (next) next();
    } else {
      this.locked = false;
    }
  }
}

export { Mutex };