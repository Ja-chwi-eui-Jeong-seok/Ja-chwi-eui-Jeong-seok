abstract interface class GeminiDataSource {
  //일반 메세지전송
  Future<String> sendMessage(String message, List<Map<String, String>> history);

  //냉장고 재료 기반으로 레시피 생성
  Future<String> generateRecipe(
    List<String> ingredients,
    List<Map<String, String>> history,
  );
  //인삿말
  Future<String> generateGreeting();
}
