abstract class EndpointBase<R, T> {
  Future<R> request(T data);
}
