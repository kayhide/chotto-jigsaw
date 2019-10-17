export default class Command {
  static commit() {
    const cmds = this.squash();
    this.commands.concat(cmds);
    this.onCommit.forEach(fnc => fnc(cmds));
    return cmds;
  }

  static post(cmd) {
    if (cmd.isValid()) {
      cmd.execute();
      this.current_commands.push(cmd);
      this.onPost.forEach(fnc => fnc(cmd));
    } else {
      cmd.rejected = true;
      this.onReject.forEach(fnc => fnc(cmd));
    }
    return cmd;
  }

  static squash() {
    let last = null;
    return _(this.current_commands).reduce((acc, cmd) => {
      if (!(last && last.squash(cmd))) {
        last = cmd;
        return [cmd, ...acc];
      }
      return acc;
    }, []);
    // const cmds = [];
    // let last = null;
    // let cmd = null;
    // while ((cmd = this.current_commands.shift())) {
    //   if (!(last && last.squash(cmd))) {
    //     last = cmd;
    //     cmds.push(cmd);
    //   }
    // }
    // return cmds;
  }

  post() {
    Command.post(this);
  }

  commit() {
    Command.post(this);
    Command.commit();
    return this;
  }

  squash() {
    return false;
  }

  isValid() {
    return true;
  }
}

Command.onCommit = [];
Command.onPost = [];
Command.onReject = [];
Command.commands = [];
Command.current_commands = [];
