#include <Rcpp.h>
#include <map>
#include <string>
#include <iostream>
using namespace Rcpp;

List wrap_custom(const std::map<std::string, unsigned long long int> dict){ 
  std::vector<unsigned long long int> kmer_output;
  std::vector<std::string> kmer_string;
  for(auto i = dict.begin(), n = dict.end(); i != n; i++){
    kmer_string.push_back(i->first); 
    kmer_output.push_back(i->second); 
  }
  return List::create(Named("kmer_string") = kmer_string, 
                      Named("kmer_value") = kmer_output); 
}

List wrap_custom(const std::map<unsigned long long int, unsigned long long int> dict){
  std::vector<unsigned long long int> kmer_index;
  std::vector<unsigned long long int> kmer_output;
  for(auto i = dict.begin(), n = dict.end(); i != n; i++){
    kmer_index.push_back(i->first);
    kmer_output.push_back(i->second);
  }
  return List::create(Named("kmer_index") = kmer_index,
                      Named("kmer_value") = kmer_output);
}

List wrap_custom(const std::vector<unsigned long long int> v){
  return List::create(v);
}

CharacterVector wrap_custom(const std::vector<std::string> s){
  std::cout << "applying custom wrapper to char vec" << std::endl;
  return(Rcpp::wrap(s));
}

// [[Rcpp::export]]
List kmers(const CharacterVector& x, int kmer = 3) {
  // Simple kmer algorithm that returns a named R list with simple kmer strings
  // and counts
  std::string dna_string = as<std::string>(x); 
  std::map<std::string, unsigned long long int> kmer_dict; 
  unsigned long long int n = dna_string.size() + 1 - kmer;
  for(unsigned int i = 0; i < n; i++){
    auto kmer_i = dna_string.substr(i, kmer); 
    if(kmer_dict.find(kmer_i) == kmer_dict.end()){
      kmer_dict[kmer_i] = 1; 
    } else {
      kmer_dict[kmer_i] = kmer_dict[kmer_i] + 1; 
    }
  }
  std::vector<unsigned long long int> kmer_output;
  std::vector<std::string> kmer_string;
  for(auto i = kmer_dict.begin(), n = kmer_dict.end(); i != n; i++){
    kmer_string.push_back(i->first); 
    kmer_output.push_back(i->second); 
  }
  return List::create(Named("kmer_string") = kmer_string, 
                      Named("kmer_value") = kmer_output); 
}

std::vector<std::string> permute_kmers(int k, std::string& b){
  std::sort(b.begin(), b.end()); 
  std::vector<std::string> output_s; 
  char max_char = b.back(); 
  char min_char = b.front(); 
  std::string min_string;  
  for(int i = 0; i < k; i++){ 
    min_string.push_back(min_char);
  }
  std::string max_string; 
  for(int i = 0; i < k; i++){
    max_string.push_back(max_char); 
  }
  
  output_s.push_back(min_string);
  
  while(output_s.back() < max_string){
    std::string working_string = output_s.back(); 
    auto working_char = working_string.rbegin(); 
    
    while(working_char != working_string.rend()){
      if(*working_char < max_char){
        break; 
      } else {
        *working_char = b.front(); 
        working_char++; 
      }
    }
    auto working_char_index = b.find(*working_char); 
    char new_char = b[working_char_index + 1]; 
    *working_char = new_char; 
    output_s.push_back(working_string); 
  }
  return output_s;
}

// [[Rcpp::export]]
CharacterVector generate_kmer_perms(int k, const CharacterVector& bases){
  /* This is my own algorithm, that lexiconographically increments
   * a string of length k to find all permutations with repetition of 
   * provided bases. Returns an R CharacterVector of all permutations */
  std::string input_bases = Rcpp::as<std::string>(bases); 
  std::vector<std::string> perms = permute_kmers(k, input_bases);
  return wrap_custom(perms); 
}


std::map<std::string, unsigned long long int> generate_kmer_perm_dict(int k, std::string b = "ACTG") {
  // "Private" function to generate a map of all possible kmers initialised to 
  // counts of 0
  std::sort(b.begin(), b.end()); 
  std::map<std::string, unsigned long long int> output_s; 
  char max_char = b.back(); 
  char min_char = b.front(); 
  std::string min_string;  
  for(int i = 0; i < k; i++){ 
    min_string.push_back(min_char);
  }
  std::string max_string; 
  for(int i = 0; i < k; i++){
    max_string.push_back(max_char); 
  }
  
  output_s[min_string] = 0;

  while(output_s.rbegin()->first < max_string){
    std::string working_string = output_s.rbegin()->first; 
    auto working_char = working_string.rbegin(); 
    
    while(working_char != working_string.rend()){
      if(*working_char < max_char){
        break; 
      } else {
        *working_char = b.front(); 
        working_char++; 
      }
    }
    auto working_char_index = b.find(*working_char); 
    char new_char = b[working_char_index + 1]; 
    *working_char = new_char; 
    output_s[working_string] = 0; 
  }
  return output_s; 
}


std::map<std::string, unsigned long long int> make_kmer_paired_list(
    const std::string& x, int kmer, bool drop_n = false, 
    std::map<std::string, unsigned long long int> kmer_dict = {}) {
  // "Private" function that generates a paired named R list of kmers and 
  // counts, functionally identical to kmers()
  //std::map<std::string, int> kmer_dict; 
  unsigned long long int n = x.size() + 1 - kmer;
  for(unsigned long long int i = 0; i < n; i++){
    auto kmer_i = x.substr(i, kmer); 
    
    // Drop kmers that contain N if drop_n = true
    if(drop_n & (kmer_i.find("N") != std::string::npos)) continue; 
    
    if(kmer_dict.find(kmer_i) == kmer_dict.end()){
      kmer_dict[kmer_i] = 1; 
    } else if (kmer_dict[kmer_i] == 0){
      kmer_dict[kmer_i] = 1; 
    } else {
      kmer_dict[kmer_i] = kmer_dict[kmer_i] + 1; 
    }
  }
  return kmer_dict; 
}

template<typename T>
bool is_valid_dna_string(T dna){
  return dna.size() > 0 ? true : false; 
}

std::map<unsigned long long int, unsigned long long int> convert_kmer_string_to_index(
  std::map<std::string, unsigned long long int> x, 
  int k,
  int index) {
    std::map<unsigned long long int, unsigned long long int> output_dict;
    auto perms_dict = generate_kmer_perm_dict(k);
    for(auto i = perms_dict.begin(), n = perms_dict.end(); i != n; i++){
      i->second = index; 
      index++;
    }
    for(auto i = x.begin(), n = x.end(); i != n; i++) {
      unsigned long long int key_as_index = perms_dict[i->first]; 
      output_dict[key_as_index] = i->second;
    }
    return output_dict;
  }

// [[Rcpp::export]]
List kmers_pointed(const CharacterVector& x, int kmer = 3, 
                   bool simplify = false, 
                   bool anchor = true, 
                   bool clean_up = true,
                   bool key_as_int = false,
                   bool starting_index = 0) {
  // "Public" function that returns an R list of kmers. By default this is anchored
  // with all possible kmers (if none recorded in genome then = 0). If anchor=false
  // then currently behaves identically to kmers()
  // If simplify = true, returns a numeric vector of kmer counts, without 
  // associated string. This is useful to save memory, but should always be used
  // with anchor = true. 
  // clean_up deals with missing data ("N") by dropping respective kmers
  std::string dna_string = as<std::string>(x); 
  if (!is_valid_dna_string(dna_string)) return List(); 

  if (key_as_int) {
    auto string_key = make_kmer_paired_list(dna_string, kmer, clean_up);
    auto int_key = convert_kmer_string_to_index(string_key, kmer, starting_index);
    return wrap_custom(int_key);
  }
  if (anchor) {
    std::map<std::string, unsigned long long int> mapped = generate_kmer_perm_dict(kmer, "ACTG"); 
    if (simplify) {
      std::map<std::string, unsigned long long int> temp_dict = make_kmer_paired_list(dna_string, kmer, clean_up, mapped); 
      std::vector<unsigned long long int> kmer_output; 
      for(auto i = temp_dict.begin(), n = temp_dict.end(); i != n; i++){
        kmer_output.push_back(i->second);
      }
      return wrap_custom(kmer_output); 
    }
    else {
      return wrap_custom(make_kmer_paired_list(dna_string, kmer, clean_up, mapped));
    }
  }
  else {
    if (simplify) {
      std::map<std::string, 
               unsigned long long int> temp_dict = make_kmer_paired_list(dna_string, kmer, clean_up); 
      std::vector<unsigned long long int> kmer_output; 
      for (auto i = temp_dict.begin(), n = temp_dict.end(); i != n; i++){
        kmer_output.push_back(i->second); 
      }
      return wrap_custom(kmer_output); 
    }
    return wrap_custom(make_kmer_paired_list(dna_string, kmer, clean_up)); 
  }
}

// [[Rcpp::export]]
void kmer_hash_table(const CharacterVector& x, int k, int index = 0){

}
