import Piece from "../model/piece";
import CommandGroup from "./command_group";

export default abstract class Command {
  static history: Array<CommandGroup> = [];
  static current: CommandGroup = CommandGroup.create();

  static onPost: Array<(Command) => void> = [];
  static onCommit: Array<(Command) => void> = [];
  static onReject: Array<(Command) => void> = [];

  static commit(): void {
    const cmds = this.current;
    this.current = CommandGroup.create();
    this.history.push(cmds);
    this.onCommit.forEach(fnc => fnc(cmds));
  }

  static post(cmd: Command): void {
    if (cmd.isValid()) {
      cmd.execute();
      this.current.squash(cmd);
      this.onPost.forEach(fnc => fnc(cmd));
    } else {
      cmd.rejected = true;
      this.onReject.forEach(fnc => fnc(cmd));
    }
  }

  static receive(cmds: CommandGroup): void {
    cmds.extrinsic = true;
    cmds.forEach(cmd => this.onPost.forEach(fnc => fnc(cmd)));
    this.history.push(cmds);
    this.onCommit.forEach(fnc => fnc(cmds));
  }

  piece: Piece;
  rejected = false;

  abstract execute(): void;

  post(): void {
    Command.post(this);
  }

  commit(): Command {
    Command.post(this);
    Command.commit();
    return this;
  }

  squash(_cmd: Command): Command | null {
    return null;
  }

  isValid(): boolean {
    return true;
  }
}
