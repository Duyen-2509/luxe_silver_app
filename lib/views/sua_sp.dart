import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import '../models/sanPham_model.dart';
import '../controllers/product_controller.dart';
import '../repository/product_repository.dart';
import '../services/api_service.dart';

class EditProductScreen extends StatefulWidget {
  final SanPham sanPham;
  const EditProductScreen({Key? key, required this.sanPham}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController accessoryController = TextEditingController();
  final TextEditingController materialController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String gender = 'Nữ';
  String type = 'Lẻ';
  String sizeUnit = 'mm';
  bool isFreesize = false;
  List<Map<String, String>> sizeList = [];
  // Danh sách các loại phụ kiện
  final List<String> accessoryOptions = [
    'Dây chuyền',
    'Nhẫn',
    'Lắc tay',
    'Bông tai',
    'Lắc chân',
    'Mặt dây',
    'Nhẫn đôi',
    'Dây chuyền đôi',
    'Vòng tay đôi',
    'Bộ',
  ];
  String? selectedAccessory;

  // Ảnh mới chọn
  List<XFile> productImages = [];
  // Ảnh cũ (url hoặc tên file)
  List<String> oldImages = [];
  // Danh sách ảnh cũ được chọn để xóa
  List<String> deleteImages = [];

  @override
  void initState() {
    super.initState();
    // Gán dữ liệu cũ vào form
    nameController.text = widget.sanPham.tensp;
    accessoryController.text = widget.sanPham.tenpk ?? '';
    selectedAccessory = widget.sanPham.tenpk;
    materialController.text = widget.sanPham.chatlieu;
    descriptionController.text = widget.sanPham.mota ?? '';
    gender = widget.sanPham.gioitinh;
    if (widget.sanPham.idLoai == 2) {
      type = 'Đôi';
    } else if (widget.sanPham.idLoai == 3) {
      type = 'Bộ';
    } else {
      type = 'Lẻ';
    }
    // Size list
    sizeList =
        widget.sanPham.details
            ?.map(
              (d) => {
                'size': d.kichthuoc,
                'quantity': d.soluongKho.toString(),
                'price': d.gia.toString(),
                'donvi': d.donvi,
              },
            )
            .toList() ??
        [
          {'size': '', 'quantity': '', 'price': '', 'donvi': 'mm'},
        ];
    sizeUnit = sizeList.isNotEmpty ? (sizeList[0]['donvi'] ?? 'mm') : 'mm';
    isFreesize =
        sizeList.length == 1 &&
        (sizeList[0]['donvi']?.toLowerCase() == 'freesize');
    // Ảnh cũ
    oldImages = widget.sanPham.images ?? [];
  }

  Future<void> _pickImagesFromGallery() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() {
        productImages.addAll(selectedImages);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        productImages.add(photo);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      productImages.removeAt(index);
    });
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.alertDialog,
          title: const Text('Chọn nguồn ảnh'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Thư viện ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImagesFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleDeleteOldImage(String img) {
    setState(() {
      if (deleteImages.contains(img)) {
        deleteImages.remove(img);
      } else {
        deleteImages.add(img);
      }
    });
  }

  void _saveProduct() async {
    // Chuẩn hóa sizeList nếu là freesize
    if (isFreesize) {
      sizeList[0]['size'] = '0';
      sizeList[0]['donvi'] = 'freesize';
    }
    int idLoai = 1;
    if (type == 'Đôi') idLoai = 2;
    if (type == 'Bộ') idLoai = 3;

    List<File> images = productImages.map((xfile) => File(xfile.path)).toList();

    final controller = ProductController(ProductRepository(ApiService()));

    print('DEBUG UPDATE PRODUCT:');
    print('id: ${widget.sanPham.idSp}');
    print('tensp: ${nameController.text}');
    print('gioitinh: $gender');
    print('chatlieu: ${materialController.text}');
    print('tenpk: ${accessoryController.text}');
    print('idLoai: $idLoai');
    print('mota: ${descriptionController.text}');
    print('trangthai: ${widget.sanPham.trangthai ?? 1}');
    print('isFreesize: $isFreesize');
    print('sizeList: $sizeList');
    print('images: ${images.map((e) => e.path).toList()}');
    print('deleteImages: $deleteImages');

    final result = await controller.updateProduct(
      id: widget.sanPham.idSp,
      tensp: nameController.text,
      gioitinh: gender,
      chatlieu: materialController.text,
      tenpk: accessoryController.text,
      idLoai: idLoai,
      mota: descriptionController.text,
      trangthai: widget.sanPham.trangthai ?? 1,
      images: images,
      deleteImages: deleteImages,
      sizes: sizeList,
      isFreesize: isFreesize,
      donvi: sizeUnit,
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'Thông báo',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: Text(
              result ?? 'Có lỗi xảy ra',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context, rootNavigator: true).pop();
      if (result != null && result.contains('thành công')) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa sản phẩm'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Ảnh cũ: cho phép chọn để xóa
              if (oldImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ảnh hiện tại (chọn để xóa):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: oldImages.length,
                        itemBuilder: (context, index) {
                          final img = oldImages[index];
                          final isSelected = deleteImages.contains(img);
                          return GestureDetector(
                            onTap: () => _toggleDeleteOldImage(img),
                            child: Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? Colors.red
                                              : Colors.transparent,
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      img,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              // Ảnh mới chọn
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ảnh mới (nếu có)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: _showImageSourceDialog,
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Thêm ảnh'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (productImages.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: productImages.length,
                          itemBuilder:
                              (context, index) => Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(productImages[index].path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      )
                    else
                      const Text('Chưa chọn ảnh mới'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Các trường nhập liệu
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm *'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Không được để trống'
                            : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedAccessory,
                decoration: InputDecoration(
                  label: RichText(
                    text: TextSpan(
                      text: 'Phụ kiện',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                items:
                    accessoryOptions
                        .map(
                          (option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedAccessory = val;
                    accessoryController.text = val ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Không được để trống';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: materialController,
                decoration: const InputDecoration(labelText: 'Chất liệu *'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Không được để trống'
                            : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả *'),
                maxLines: null,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Không được để trống'
                            : null,
              ),
              const SizedBox(height: 16),
              // Giới tính
              Row(
                children: [
                  const Text('Giới tính:'),
                  Radio<String>(
                    value: 'Nữ',
                    groupValue: gender,
                    onChanged: (val) => setState(() => gender = val!),
                  ),
                  const Text('Nữ'),
                  Radio<String>(
                    value: 'Nam',
                    groupValue: gender,
                    onChanged: (val) => setState(() => gender = val!),
                  ),
                  const Text('Nam'),
                  Radio<String>(
                    value: 'Unisex',
                    groupValue: gender,
                    onChanged: (val) => setState(() => gender = val!),
                  ),
                  const Text('Unisex'),
                ],
              ),
              // Loại
              Row(
                children: [
                  const Text('Loại:'),
                  Radio<String>(
                    value: 'Lẻ',
                    groupValue: type,
                    onChanged: (val) => setState(() => type = val!),
                  ),
                  const Text('Lẻ'),
                  Radio<String>(
                    value: 'Đôi',
                    groupValue: type,
                    onChanged: (val) => setState(() => type = val!),
                  ),
                  const Text('Đôi'),
                  Radio<String>(
                    value: 'Bộ',
                    groupValue: type,
                    onChanged: (val) => setState(() => type = val!),
                  ),
                  const Text('Bộ'),
                ],
              ),
              // Freesize và size
              Row(
                children: [
                  Checkbox(
                    value: isFreesize,
                    onChanged: (val) {
                      setState(() {
                        isFreesize = val!;
                        if (isFreesize) {
                          if (sizeList.isEmpty) {
                            sizeList = [
                              {
                                'size': '',
                                'quantity': '',
                                'price': '',
                                'donvi': 'freesize',
                              },
                            ];
                          } else {
                            sizeList = [
                              {
                                'size': sizeList[0]['size'] ?? '',
                                'quantity': sizeList[0]['quantity'] ?? '',
                                'price': sizeList[0]['price'] ?? '',
                                'donvi': 'freesize',
                              },
                            ];
                          }
                        } else {
                          for (var item in sizeList) {
                            item['donvi'] = 'mm';
                          }
                        }
                      });
                    },
                  ),
                  const Text('Freesize'),
                ],
              ),
              // Danh sách size
              Column(
                children: [
                  ...sizeList.asMap().entries.map((entry) {
                    int idx = entry.key;
                    return Row(
                      children: [
                        // Size
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Size *',
                            ),
                            initialValue: isFreesize ? '' : entry.value['size'],
                            enabled: !isFreesize,
                            keyboardType: TextInputType.number,
                            onChanged: (val) => sizeList[idx]['size'] = val,
                            validator: (value) {
                              if (!isFreesize &&
                                  (value == null || value.isEmpty)) {
                                return 'Không được để trống';
                              }
                              return null;
                            },
                          ),
                        ),
                        // Đơn vị
                        Expanded(
                          child:
                              isFreesize
                                  ? TextFormField(
                                    enabled: false,
                                    initialValue: 'freesize',
                                    decoration: const InputDecoration(
                                      labelText: 'Đơn vị',
                                    ),
                                  )
                                  : DropdownButtonFormField<String>(
                                    value: entry.value['donvi'] ?? 'mm',
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'mm',
                                        child: Text('mm'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'cm',
                                        child: Text('cm'),
                                      ),
                                    ],
                                    onChanged:
                                        (val) => setState(
                                          () => sizeList[idx]['donvi'] = val!,
                                        ),
                                    decoration: const InputDecoration(
                                      labelText: 'Đơn vị',
                                    ),
                                  ),
                        ),
                        const SizedBox(width: 8),
                        // Số lượng
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'SL *',
                            ),
                            initialValue: entry.value['quantity'],
                            keyboardType: TextInputType.number,
                            onChanged: (val) => sizeList[idx]['quantity'] = val,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Không được để trống';
                              final n = int.tryParse(value);
                              if (n == null || n < 0)
                                return 'Chỉ nhập số nguyên không âm';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Giá
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Giá *',
                              suffixText: 'VND',
                            ),
                            initialValue: entry.value['price'],
                            keyboardType: TextInputType.number,
                            onChanged: (val) => sizeList[idx]['price'] = val,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Không được để trống';
                              final n = int.tryParse(value);
                              if (n == null || n < 0)
                                return 'Chỉ nhập số nguyên không âm';
                              return null;
                            },
                          ),
                        ),
                        if (!isFreesize)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                sizeList.removeAt(idx);
                              });
                            },
                          ),
                      ],
                    );
                  }).toList(),
                  if (!isFreesize)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          sizeList.add({
                            'size': '',
                            'quantity': '',
                            'price': '',
                            'donvi': 'mm',
                          });
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm size'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveProduct();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Lưu sản phẩm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
