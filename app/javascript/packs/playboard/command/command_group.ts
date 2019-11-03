import Command from "./command";

export default class CommandGroup extends Array<Command> {
  static create(): CommandGroup {
    return Object.create(CommandGroup.prototype);
  }

  private constructor(items?: Array<Command>) {
    super(...items);
  }

  extrinsic = false;

  get intrinsic(): boolean {
    return !this.extrinsic;
  }

  squash(cmd: Command): void {
    const last = _.last(this);
    if (!(last && last.squash(cmd))) this.push(cmd);
  }
}
