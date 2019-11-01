import { Subscriptions } from "@rails/actioncable";
import consumer from "./consumer";

import Logger from "../playboard/logger";
import Bridge from "../playboard/bridge";
import Command from "../playboard/command/command";

export default class GameChannel {
  static subscribe(game_id: number): Subscriptions {
    return consumer.subscriptions.create(
      {
        channel: "GameChannel",
        game_id
      },
      {
        received(data: any): void {
          if (data.action === "init") {
            this.token = data.token;
          } else if (data.token !== this.token) {
            if (data.action === "commit") {
              const cmds = data.commands.map(Bridge.decode);
              cmds.forEach(cmd => {
                cmd.extrinsic = true;
                Command.post(cmd);
              });
              Command.commit();
            }
          }
        },
        commit(cmds: Array<Command>): void {
          const cmds_ = cmds.filter(cmd => !cmd.extrinsic);
          if (0 < cmds_.length) {
            this.perform("commit", { commands: cmds_.map(Bridge.encode) });
          }
        }
      }
    );
  }
}
