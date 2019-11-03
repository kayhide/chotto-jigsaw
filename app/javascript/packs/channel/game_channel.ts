import { Subscriptions } from "@rails/actioncable";
import consumer from "./consumer";

import Logger from "../common/logger";
import Bridge from "../playboard/bridge";
import Command from "../playboard/command/command";
import CommandGroup from "../playboard/command/command_group";

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
              const cmds = CommandGroup.create();
              data.commands.map(Bridge.decode).forEach(cmd => {
                cmds.squash(cmd);
              });
              Command.receive(cmds);
            }
          }
        },
        commit(cmds: CommandGroup): void {
          if (cmds.intrinsic) {
            this.perform("commit", {
              commands: cmds.map(Bridge.encode)
            });
          }
        }
      }
    );
  }
}
