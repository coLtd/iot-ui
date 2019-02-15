package com.agrithings.iot;

import org.rapidoid.config.Conf;
import org.rapidoid.net.Server;

/**
 * @author avidmouse
 * @version 1.0.0, 04/04/2018.
 */
public class Main {

    public static void main(String[] args) {

        Server server = new IotServer().listen(
                Conf.ON.entry("port").or(8200)
        );

        Runtime.getRuntime().addShutdownHook(new Thread(server::shutdown));
    }


}
