package io.agora.video.connector;

public interface SinkConnector<T> {
    int onDataAvailable(T data);
}
