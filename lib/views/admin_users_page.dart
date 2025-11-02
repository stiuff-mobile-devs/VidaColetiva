import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vidacoletiva/resources/assets/colour_pallete.dart';

enum RoleFilter { all, users, admins, superadmins }

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  RoleFilter _filter = RoleFilter.all;
  // role values: 'user', 'admin', 'superadmin'
  Map<String, String> _roles = {};
  bool _loadingRoles = false;
  final Set<String> _toggling = {};

  String _labelForFilter(RoleFilter f) {
    switch (f) {
      case RoleFilter.all:
        return 'Todos';
      case RoleFilter.users:
        return 'Apenas usuários';
      case RoleFilter.admins:
        return 'Apenas admins';
      case RoleFilter.superadmins:
        return 'Apenas superadmins';
    }
  }

  Future<void> _setRole(String uid, String role) async {
    final doc = FirebaseFirestore.instance.doc('/users/$uid/private/private');
    final data = <String, dynamic>{};
    if (role == 'superadmin') {
      data['isSuperAdmin'] = true;
      data['isAdmin'] = true;
    } else if (role == 'admin') {
      data['isSuperAdmin'] = false;
      data['isAdmin'] = true;
    } else {
      data['isSuperAdmin'] = false;
      data['isAdmin'] = false;
    }
    await doc.set(data, SetOptions(merge: true));
  }

  Future<void> _loadRolesForUids(List<String> uids) async {
    if (_loadingRoles) return;
    _loadingRoles = true;
    try {
      final refs = uids
          .map((u) =>
              FirebaseFirestore.instance.doc('/users/$u/private/private'))
          .toList();
      final futures = refs.map((r) => r.get()).toList();
      final snaps = await Future.wait(futures);
      final Map<String, String> map = {};
      for (var s in snaps) {
        final parent = s.reference.parent.parent; // users/{uid}
        if (parent == null) continue;
        final uid = parent.id;
        if (!s.exists) {
          map[uid] = 'user';
        } else {
          final data = s.data();
          final isSuper = data != null && data['isSuperAdmin'] == true;
          final isAdmin = data != null && data['isAdmin'] == true;
          if (isSuper)
            map[uid] = 'superadmin';
          else if (isAdmin)
            map[uid] = 'admin';
          else
            map[uid] = 'user';
        }
      }
      if (!mounted) return;
      setState(() {
        _roles = map;
      });
    } catch (_) {
      // ignore errors for now
    } finally {
      if (mounted) {
        setState(() {
          _loadingRoles = false;
        });
      } else {
        _loadingRoles = false;
      }
    }
  }

  bool _filterAccepts(String role) {
    if (_filter == RoleFilter.all) return true;
    if (_filter == RoleFilter.users)
      return role != 'admin' && role != 'superadmin';
    if (_filter == RoleFilter.admins) return role == 'admin';
    return role == 'superadmin';
  }

  @override
  Widget build(BuildContext context) {
    // No provider usage required in this screen; checking current user via FirebaseAuth when needed.

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Moderação — Usuários',
            style: TextStyle(fontSize: 20, color: Colors.white)),
        backgroundColor: AppColors.primaryOrange,
        actions: [
          PopupMenuButton<RoleFilter>(
            onSelected: (f) => setState(() => _filter = f),
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: RoleFilter.all,
                  child: Text(_labelForFilter(RoleFilter.all))),
              PopupMenuItem(
                  value: RoleFilter.users,
                  child: Text(_labelForFilter(RoleFilter.users))),
              PopupMenuItem(
                  value: RoleFilter.admins,
                  child: Text(_labelForFilter(RoleFilter.admins))),
              PopupMenuItem(
                  value: RoleFilter.superadmins,
                  child: Text(_labelForFilter(RoleFilter.superadmins))),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          // batch-load roles for all users currently in the snapshot
          final uids = docs.map((d) => d.id).toList();
          if (!_loadingRoles) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadRolesForUids(uids);
            });
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final uid = doc.id;
              final email = doc.data()['email'] ?? uid;

              final role = _roles.containsKey(uid) ? _roles[uid]! : 'user';

              if (!_filterAccepts(role)) return const SizedBox.shrink();

              final isSelf = FirebaseAuth.instance.currentUser?.uid == uid;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(email),
                  subtitle: Text(role == 'superadmin'
                      ? 'Superadmin'
                      : (role == 'admin' ? 'Admin' : 'Usuário')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelf)
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child:
                              Icon(Icons.person, size: 20, color: Colors.grey),
                        ),
                      if (_toggling.contains(uid))
                        const SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator())
                      else
                        ElevatedButton.icon(
                          icon: Icon(
                              role == 'superadmin'
                                  ? Icons.shield
                                  : (role == 'admin'
                                      ? Icons.admin_panel_settings
                                      : Icons.person_outline),
                              size: 18),
                          label: Text(role == 'superadmin'
                              ? 'Superadmin'
                              : (role == 'admin' ? 'Admin' : 'Usuário')),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            backgroundColor: role == 'superadmin'
                                ? Colors.green
                                : (role == 'admin'
                                    ? Colors.blue
                                    : AppColors.primaryOrange),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: isSelf
                              ? null
                              : () async {
                                  final scaffold =
                                      ScaffoldMessenger.of(context);
                                  final selected = await showDialog<String>(
                                    context: context,
                                    builder: (ctx) => SimpleDialog(
                                      title: const Text('Escolher cargo'),
                                      children: [
                                        SimpleDialogOption(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop('user'),
                                          child: const Text('Usuário'),
                                        ),
                                        SimpleDialogOption(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop('admin'),
                                          child: const Text('Admin'),
                                        ),
                                        SimpleDialogOption(
                                          onPressed: () => Navigator.of(ctx)
                                              .pop('superadmin'),
                                          child: const Text('Superadmin'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (selected == null || selected == role)
                                    return;
                                  final want = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(selected == 'superadmin'
                                          ? 'Promover a Superadmin'
                                          : (selected == 'admin'
                                              ? 'Promover a Admin'
                                              : 'Rebaixar para Usuário')),
                                      content: Text(selected == 'superadmin'
                                          ? 'Tem certeza que deseja promover este usuário a superadmin?'
                                          : (selected == 'admin'
                                              ? 'Tem certeza que deseja promover este usuário a admin?'
                                              : 'Tem certeza que deseja rebaixar este usuário para Usuário?')),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: const Text('Cancelar')),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: const Text('Confirmar')),
                                      ],
                                    ),
                                  );
                                  if (want != true) return;
                                  setState(() => _toggling.add(uid));
                                  try {
                                    await _setRole(uid, selected);
                                    if (!mounted) return;
                                    setState(() {
                                      _roles[uid] = selected;
                                      _toggling.remove(uid);
                                    });
                                    scaffold.showSnackBar(SnackBar(
                                        content: Text(
                                            'Cargo atualizado para ${selected == 'superadmin' ? 'Superadmin' : (selected == 'admin' ? 'Admin' : 'Usuário')}')));
                                  } catch (e) {
                                    if (!mounted) return;
                                    setState(() => _toggling.remove(uid));
                                    scaffold.showSnackBar(
                                        SnackBar(content: Text('Erro: $e')));
                                  }
                                },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
