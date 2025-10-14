import 'package:ja_chwi/domain/entities/help_entity.dart';

abstract class HelpRepository {
  Stream<List<HelpEntity>> getHelps();
  Future<void> addHelp(HelpEntity help);
  Future<void> updateHelp(HelpEntity help);
  Future<void> softDeleteHelp(String id, String deletedBy);
}
