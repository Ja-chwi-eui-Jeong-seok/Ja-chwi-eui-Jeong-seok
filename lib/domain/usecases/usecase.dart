// T: 결과 타입 (ex. List<Category>)
// P: 입력 파라미터 타입 (ex. int categoryCode)
// call 메서드: 실행 함수. Dart에서는 call()이 있으면 객체를 함수처럼 쓸 수 있음.

abstract interface class Usecase<T, P> {
  Future<T> call(P params);
}
