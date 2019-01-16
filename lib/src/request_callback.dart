class BaseRequestCallback<T> {

  BaseRequestCallback(this.onStart, this.onCompleted, this.onError);

  Function onStart;

  Function(T) onCompleted;

  Function(dynamic e) onError;
}