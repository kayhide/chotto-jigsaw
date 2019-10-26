import Piece from "../model/piece";

export default abstract class Command {
  static commands: Array<Command> = [];
  static currentCommands: Array<Command> = [];

  static onPost: Array<(Command) => void> = [];
  static onCommit: Array<(Command) => void> = [];
  static onReject: Array<(Command) => void> = [];

  static commit(): void {
    const cmds = Command.squash();
    Command.commands.concat(cmds);
    Command.onCommit.forEach(fnc => fnc(cmds));
  }

  static post(cmd: Command): void {
    if (cmd.isValid()) {
      cmd.execute();
      Command.currentCommands.push(cmd);
      Command.onPost.forEach(fnc => fnc(cmd));
    } else {
      cmd.rejected = true;
      Command.onReject.forEach(fnc => fnc(cmd));
    }
  }

  static squash(): Array<Command> {
    let last = null;
    return _(Command.currentCommands).reduce((acc, cmd) => {
      if (!(last && last.squash(cmd))) {
        last = cmd;
        return [cmd, ...acc];
      }
      return acc;
    }, []);
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

  squash(_cmd: Command): boolean {
    return false;
  }

  isValid(): boolean {
    return true;
  }
}
