import Piece from "../model/piece";

export default abstract class Command {
  static commands: Array<Command> = [];
  static currentCommands: Array<Command> = [];

  static onPost: Array<(Command) => void> = [];
  static onCommit: Array<(Command) => void> = [];
  static onReject: Array<(Command) => void> = [];

  static commit(): void {
    const cmds = Command.currentCommands;
    Command.commands.concat(cmds);
    Command.currentCommands = [];
    Command.onCommit.forEach(fnc => fnc(cmds));
  }

  static post(cmd: Command): void {
    if (cmd.isValid()) {
      cmd.execute();
      const last = _.last(Command.currentCommands);
      (last && last.squash(cmd)) || Command.currentCommands.push(cmd);
      Command.onPost.forEach(fnc => fnc(cmd));
    } else {
      cmd.rejected = true;
      Command.onReject.forEach(fnc => fnc(cmd));
    }
  }

  piece: Piece;
  rejected = false;
  extrinsic = false;

  abstract execute(): void;

  post(): void {
    Command.post(this);
  }

  commit(): Command {
    Command.post(this);
    Command.commit();
    return this;
  }

  squash(_cmd: Command): boolean {
    return false;
  }

  isValid(): boolean {
    return true;
  }
}
