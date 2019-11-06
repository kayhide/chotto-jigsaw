import * as Logger from "../../common/Logger.bs";
import * as EventHandler from "../../common/EventHandler.bs";
import Piece from "../model/piece";
import CommandGroup from "./command_group";

export default abstract class Command {
  static history: Array<CommandGroup> = [];
  static current: CommandGroup = CommandGroup.create();

  static postHandler = EventHandler.create();
  static commitHandler = EventHandler.create();

  static onPost(handler: (Command) => void): void {
    this.postHandler = EventHandler.append(handler, this.postHandler);
  }

  static onCommit(handler: (CommandGroup) => void): void {
    this.commitHandler = EventHandler.append(handler, this.commitHandler);
  }

  static commit(): void {
    const cmds = this.current;
    this.current = CommandGroup.create();
    this.history.push(cmds);
    EventHandler.fire(cmds, this.commitHandler);
  }

  static post(cmd: Command): void {
    if (cmd.isValid()) {
      cmd.execute();
      this.current.squash(cmd);
      EventHandler.fire(cmd, this.postHandler);
    }
  }

  static receive(cmds: CommandGroup): void {
    cmds.extrinsic = true;
    cmds.forEach(cmd => cmd.execute());
    this.history.push(cmds);
    EventHandler.fire(cmds, this.commitHandler);
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
