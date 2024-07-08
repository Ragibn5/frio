import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'error_mapper.dart';
import 'model_coder.dart';

class FrioClient<MappedErrorType> {
  final _dio = Dio();

  final ModelCoder _coder;
  final ErrorMapper<MappedErrorType> _errorMapper;

  /// **Create a Frio client.**
  /// - Provide a [baseUrl] which will be used as the base url of all the
  /// api calls made with this [FrioClient] instance. This will override
  /// [baseOptions.baseUrl].
  /// - Provide a subclass of [ModelCoder] which will be used to
  /// serialize/deserialize requests/responses.
  /// - Provide a subclass of [ErrorMapper] which will be used to map
  /// exceptions or errors thrown by the underlying dio instance to your
  /// expected type (specified by [MappedErrorType]).
  /// - Provide any optional interceptors here to watch or process the
  /// requests, responses and errors.
  FrioClient({
    required String baseUrl,
    required ModelCoder coder,
    required ErrorMapper<MappedErrorType> errorMapper,
    List<Interceptor> interceptors = const [],
    BaseOptions? baseOptions,
  })  : _coder = coder,
        _errorMapper = errorMapper {
    // merge base options
    if (baseOptions != null) {
      _mergeBaseOptions(_dio.options, baseOptions);
    }

    // overwrite custom standalone options
    _dio.options.baseUrl = baseUrl;

    // add interceptors
    _dio.interceptors.addAll(interceptors);
  }

  /// **Execute a raw request**.
  ///
  /// Some properties of the passed [Options] instance, specifically,
  /// [options.baseUrl] and [options.path] of the [options] parameter
  /// will be overridden by [path] & [baseUrl] parameters.
  Future<Either<MappedErrorType, ResultType>> execute<ResultType>(
      String path, {
        String? baseUrl,
        required RequestOptions options,
      }) {
    return _processResponse<ResultType>(
      _dio.fetch(
        options.copyWith(
          path: path,
          baseUrl: baseUrl ?? _dio.options.baseUrl,
        ),
      ),
    );
  }

  /// **Execute a get request**.
  Future<Either<MappedErrorType, ResultType>> get<ResultType>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
      }) {
    return _processResponse<ResultType>(
      _dio.get(
        path,
        data: _buildRequest(data),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  /// **Execute a post request**.
  Future<Either<MappedErrorType, ResultType>> post<ResultType>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
      }) {
    return _processResponse<ResultType>(
      _dio.post(
        path,
        data: _buildRequest(data),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  /// **Execute a put request**.
  Future<Either<MappedErrorType, ResultType>> put<ResultType>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
      }) {
    return _processResponse<ResultType>(
      _dio.put(
        path,
        data: _buildRequest(data),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  /// **Execute a delete request**.
  Future<Either<MappedErrorType, ResultType>> delete<ResultType>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) {
    return _processResponse<ResultType>(
      _dio.delete(
        path,
        data: _buildRequest(data),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// **Execute a patch request**.
  Future<Either<MappedErrorType, ResultType>> patch<ResultType>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
      }) {
    return _processResponse<ResultType>(
      _dio.patch(
        path,
        data: _buildRequest(data),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  /// Only use this if absolutely necessary.
  /// One use case would be inside interceptor where we need raw response.
  Dio getCoreDioClient() => _dio;

  dynamic _buildRequest(dynamic requestData) {
    return requestData != null ? _coder.encode(requestData) : null;
  }

  Future<Either<MappedErrorType, ResultType>> _processResponse<ResultType>(
      final Future<Response<dynamic>> asyncRunnable,
      ) async {
    try {
      return Right(_coder.decode<ResultType>((await asyncRunnable).data));
    } on Exception catch (e) {
      debugPrint(e.toString());
      return Left(_errorMapper.mapError(e));
    }
  }

  // Merges [newBaseOptions] on top of [destBaseOptions].
  void _mergeBaseOptions(
      BaseOptions newBaseOptions,
      BaseOptions destBaseOptions,
      ) {
    destBaseOptions.method = newBaseOptions.method;
    destBaseOptions.connectTimeout = newBaseOptions.connectTimeout;
    destBaseOptions.receiveTimeout = newBaseOptions.receiveTimeout;
    destBaseOptions.sendTimeout = newBaseOptions.sendTimeout;
    destBaseOptions.responseType = newBaseOptions.responseType;
    destBaseOptions.contentType = newBaseOptions.contentType;
    destBaseOptions.validateStatus = newBaseOptions.validateStatus;
    destBaseOptions.receiveDataWhenStatusError =
        newBaseOptions.receiveDataWhenStatusError;
    destBaseOptions.followRedirects = newBaseOptions.followRedirects;
    destBaseOptions.maxRedirects = newBaseOptions.maxRedirects;
    destBaseOptions.persistentConnection = newBaseOptions.persistentConnection;
    destBaseOptions.requestEncoder = newBaseOptions.requestEncoder;
    destBaseOptions.responseDecoder = newBaseOptions.responseDecoder;
    destBaseOptions.listFormat = newBaseOptions.listFormat;
    destBaseOptions.extra.addAll(newBaseOptions.extra);
    destBaseOptions.headers.addAll(newBaseOptions.headers);
    destBaseOptions.queryParameters.addAll(newBaseOptions.queryParameters);
  }
}
