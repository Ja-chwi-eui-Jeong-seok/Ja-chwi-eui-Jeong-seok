import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/domain/entities/category.dart';
import 'package:ja_chwi/presentation/providers/category_provider.dart';

class CategoryState {
  final AsyncValue<List<Category>> parents;
  final Map<int, AsyncValue<List<CategoryDetail>>> children;
  CategoryState({
    this.parents = const AsyncValue.loading(),
    this.children = const {},
  });

  //상태 복사본 생성
  CategoryState copyWith({
    AsyncValue<List<Category>>? parents,
    Map<int, AsyncValue<List<CategoryDetail>>>? children,
  }) => CategoryState(
    parents: parents ?? this.parents,
    children: children ?? this.children,
  );
}

//CategoryState상태를 보관하고 바꿔주는 클래스,Provider로 접근 가능
class CategoryVM extends Notifier<CategoryState> {
  @override
  CategoryState build() {
    Future.microtask(_loadParents); //초기 생성시 상위 카테고리 로드
    return CategoryState();
  }

  //상위 카테고리 불러오기
  Future<void> _loadParents() async {
    final uc = ref.read(getCategoryProvider); //유즈케이스 실행
    //→ 로딩 → 성공/실패 자동처리.
    //UI에서는 ref.watch(...).when(data:..., loading:..., error:...) 패턴으로 깔끔하게 대응 가능.
    state = state.copyWith(parents: AsyncValue.loading());
    state = state.copyWith(
      // AsyncValue.guard → 성공/실패/로딩 상태를 한 번에 핸들링
      parents: await AsyncValue.guard(() => uc.call(null)),
    );
  }

  //특정 상위카테고리 성택 시 하위 카테고리 불러오기
  Future<void> loadChildren(int code) async {
    //(state.children[code] is AsyncData) = "이미 성공적으로 데이터 있음" → 캐싱
    if (state.children[code] is AsyncData) return;
    final uc = ref.read(getCategoryDetailsProvider);

    //로딩상태
    final newMap = Map<int, AsyncValue<List<CategoryDetail>>>.from(
      state.children,
    )..[code] = const AsyncValue.loading();
    state = state.copyWith(children: newMap);

    //실제데이터 패치
    final res = await AsyncValue.guard(() => uc.call(code));
    newMap[code] = res;

    //최종상태변경
    state = state.copyWith(children: newMap);
  }
}

//Provider등록
final categoryVMProvider = NotifierProvider<CategoryVM, CategoryState>(
  CategoryVM.new,
);
