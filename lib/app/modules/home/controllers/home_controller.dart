import 'package:chatwithdocs/app/utils/logger.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

class HomeController extends GetxController {
  RxString text = ''.obs;
  String srcPath = '';
  RxString result = ''.obs;

  extractPdfText() async {
    //Pick a PDF document from the device.
    var filePickerResult = await FilePicker.platform.pickFiles();
    if (filePickerResult == null) return;

    //Load an existing PDF document.
    final PdfDocument document = PdfDocument(
        inputBytes:
            File(filePickerResult.files.single.path!).readAsBytesSync());
    //Extract the text from all the pages.
    text.value = PdfTextExtractor(document).extractText();
    //Save the extracted text to a text file.
    await writeString(
        text: text.value, fileName: filePickerResult.files.single.name);
    //Dispose the document.
    document.dispose();

    await chains();
  }

  Future<File> writeString(
      {required String text, required String fileName}) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${fileName.toLowerCase()}.txt');

    logger.d("File Path: ${file.path}");
    srcPath = file.path;
    return file.writeAsString(text);
  }

  chains() async {
    final loader = TextLoader(srcPath);
    final documents = await loader.load();
    const textSplitter = CharacterTextSplitter(
      chunkSize: 1000,
      chunkOverlap: 0,
    );
    final texts = textSplitter.splitDocuments(documents);
    final textsWithSources = texts
        .asMap()
        .entries
        .map(
          (final entry) => entry.value.copyWith(
            metadata: {
              ...entry.value.metadata,
              'source': '${entry.key}-pl',
            },
          ),
        )
        .toList(growable: false);

    final embeddings = OpenAIEmbeddings(apiKey: openAiKey);
    final docSearch = await MemoryVectorStore.fromDocuments(
      documents: textsWithSources,
      embeddings: embeddings,
    );
    final llm = ChatOpenAI(
      apiKey: openAiKey,
      defaultOptions: const ChatOpenAIOptions(temperature: 0.2),
    );
    final qaChain = OpenAIQAWithSourcesChain(llm: llm);
    final docPrompt = PromptTemplate.fromTemplate(
      'Content: {page_content}\nSource: {source}',
    );
    final finalQAChain = StuffDocumentsChain(
      llmChain: qaChain,
      documentPrompt: docPrompt,
    );
    final retrievalQA = RetrievalQAChain(
      retriever: docSearch.asRetriever(),
      combineDocumentsChain: finalQAChain,
    );
    const query = 'Whose CV is this? what are his skills?';
    final res = await retrievalQA(query);
    logger.d(res);
  }
}
