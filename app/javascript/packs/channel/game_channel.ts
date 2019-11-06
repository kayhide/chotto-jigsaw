import { Subscriptions } from "@rails/actioncable";
import consumer from "./consumer";

import * as Logger from "../common/Logger.bs";
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
          Logger.trace(`received: ${data.action}`);
          if (data.action === "init") {
            this.token = data.token;
            this.perform("request_update", {});
          } else if (data.token !== this.token) {
            if (data.action === "commit") {
              const cmds = CommandGroup.create();
              data.commands.forEach(x => {
                cmds.squash(Bridge.decode(x));
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
