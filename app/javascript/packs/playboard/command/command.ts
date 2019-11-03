import Logger from "../../common/logger";
import EventHandler from "../../common/event_handler";
import Piece from "../model/piece";
import CommandGroup from "./command_group";

export default abstract class Command {
  static history: Array<CommandGroup> = [];
  static current: CommandGroup = CommandGroup.create();

  static postHandler = new EventHandler<Command>();
  static commitHandler = new EventHandler<CommandGroup>();

  static onPost(handler: (Command) => void): void {
    this.postHandler.append(handler);
  }

  static onCommit(handler: (CommandGroup) => void): void {
    this.commitHandler.append(handler);
  }

  static commit(): void {
    const cmds = this.current;
    this.current = CommandGroup.create();
    this.history.push(cmds);
    this.commitHandler.fire(cmds);
  }

  static post(cmd: Command): void {
    if (cmd.isValid()) {
      cmd.execute();
      this.current.squash(cmd);
      this.postHandler.fire(cmd);
    }
  }

  static receive(cmds: CommandGroup): void {
    cmds.extrinsic = true;
    cmds.forEach(cmd => cmd.execute());
    this.history.push(cmds);
    this.commitHandler.fire(cmds);
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
